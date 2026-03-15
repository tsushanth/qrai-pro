// PaywallView.swift
// QRAI Pro

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PremiumManager.self) private var premiumManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProductID: String = ""
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var showError = false

    private var storeKit: StoreKitManager { premiumManager.storeKit }

    let features: [(String, String)] = [
        ("Custom QR Styles", "paintbrush.pointed"),
        ("All Export Formats", "square.and.arrow.up"),
        ("Batch Generation", "square.stack.3d.up"),
        ("Social Media QR Codes", "person.2"),
        ("Logo in QR Codes", "photo"),
        ("Unlimited History", "clock.arrow.circlepath"),
        ("Priority Support", "headphones"),
        ("Remove Ads", "hand.raised"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    header

                    // Features
                    featuresGrid

                    // Products
                    if storeKit.isLoading {
                        ProgressView()
                    } else {
                        productsSection
                    }

                    // Restore
                    Button("Restore Purchases") {
                        Task { await premiumManager.restorePurchases() }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    // Legal
                    legalText
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            if let first = storeKit.subscriptions.first {
                selectedProductID = first.id
            }
            AnalyticsService.shared.track(.paywallShown(source: "paywall"))
        }
        .alert("Purchase Error", isPresented: $showError, presenting: errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: { msg in
            Text(msg)
        }
        .onChange(of: premiumManager.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppConstants.Colors.gradient)
                    .frame(width: 100, height: 100)
                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }
            .padding(.top, 24)

            Text("QRAI Pro Premium")
                .font(.title.bold())

            Text("Unlock all features and create stunning custom QR codes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var featuresGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(features, id: \.0) { feature in
                HStack(spacing: 8) {
                    Image(systemName: feature.1)
                        .foregroundStyle(AppConstants.Colors.qrBlue)
                        .frame(width: 20)
                    Text(feature.0)
                        .font(.caption)
                        .lineLimit(2)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppConstants.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 16)
    }

    private var productsSection: some View {
        VStack(spacing: 10) {
            ForEach(storeKit.subscriptions + storeKit.nonConsumables) { product in
                ProductRow(
                    product: product,
                    isSelected: selectedProductID == product.id,
                    storeKit: storeKit
                )
                .onTapGesture { selectedProductID = product.id }
            }

            // Purchase CTA
            Button(action: purchaseSelected) {
                HStack {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    }
                    Text(isPurchasing ? "Processing..." : "Continue")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(!selectedProductID.isEmpty ? AppConstants.Colors.gradient : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selectedProductID.isEmpty || isPurchasing)
            .padding(.top, 8)
        }
        .padding(.horizontal, 16)
    }

    private func purchaseSelected() {
        guard let product = storeKit.allProducts.first(where: { $0.id == selectedProductID }) else { return }
        isPurchasing = true
        AnalyticsService.shared.track(.purchaseStarted(productID: product.id))
        Task {
            do {
                try await premiumManager.purchaseProduct(product)
                AnalyticsService.shared.track(.purchaseCompleted(productID: product.id))
            } catch {
                if case QRAIStoreKitError.userCancelled = error { } else {
                    errorMessage = error.localizedDescription
                    showError = true
                }
                AnalyticsService.shared.track(.purchaseFailed(reason: error.localizedDescription))
            }
            isPurchasing = false
        }
    }

    private var legalText: some View {
        VStack(spacing: 4) {
            Text("Subscriptions auto-renew until cancelled. Cancel anytime in App Store settings.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            HStack {
                Link("Privacy Policy", destination: URL(string: "https://appfactory.app/privacy")!)
                Text("•")
                Link("Terms of Service", destination: URL(string: "https://appfactory.app/terms")!)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 32)
    }
}

struct ProductRow: View {
    let product: Product
    let isSelected: Bool
    let storeKit: StoreKitManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(product.displayName)
                        .font(.headline)
                    if let label = product.savingsLabel {
                        Text(label)
                            .font(.caption.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppConstants.Colors.qrGreen.opacity(0.15))
                            .foregroundStyle(AppConstants.Colors.qrGreen)
                            .clipShape(Capsule())
                    }
                }
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(product.displayPrice)
                    .font(.headline)
                if let period = storeKit.pricePerPeriod(for: product) {
                    Text(period)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? AppConstants.Colors.qrBlue.opacity(0.1) : AppConstants.Colors.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? AppConstants.Colors.qrBlue : Color.clear, lineWidth: 2)
                )
        )
    }
}
