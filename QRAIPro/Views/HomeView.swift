// HomeView.swift
// QRAI Pro

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(PremiumManager.self) private var premiumManager
    @Query(sort: \ScanResult.scannedAt, order: .reverse) private var recentScans: [ScanResult]
    @Query(sort: \QRCodeItem.createdAt, order: .reverse) private var recentCodes: [QRCodeItem]
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Hero Banner
                    heroBanner

                    // Quick Actions
                    quickActionsSection

                    // Recent Scans
                    if !recentScans.isEmpty {
                        recentScansSection
                    }

                    // Recent Generated
                    if !recentCodes.isEmpty {
                        recentGeneratedSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle(AppConstants.appName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !premiumManager.isPremium {
                        Button("Go Pro") { showPaywall = true }
                            .buttonStyle(.borderedProminent)
                            .tint(AppConstants.Colors.qrPurple)
                            .font(.subheadline.bold())
                    }
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var heroBanner: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(AppConstants.Colors.gradient)
            .frame(height: 140)
            .overlay {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("QRAI Pro")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Text("Scan & Generate QR Codes")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                    Image(systemName: "qrcode")
                        .font(.system(size: 60))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .padding(20)
            }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 12) {
                QuickActionCard(
                    title: "Scan",
                    icon: "qrcode.viewfinder",
                    color: AppConstants.Colors.qrBlue,
                    destination: ScannerView()
                )
                QuickActionCard(
                    title: "Generate",
                    icon: "qrcode",
                    color: AppConstants.Colors.qrPurple,
                    destination: GenerateView()
                )
            }
        }
    }

    private var recentScansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Scans")
                .font(.headline)
            ForEach(recentScans.prefix(3)) { scan in
                ScanHistoryRow(scan: scan)
            }
        }
    }

    private var recentGeneratedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Generated")
                .font(.headline)
            ForEach(recentCodes.prefix(3)) { code in
                GeneratedQRRow(code: code)
            }
        }
    }
}

struct QuickActionCard<Destination: View>: View {
    let title: String
    let icon: String
    let color: Color
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct ScanHistoryRow: View {
    let scan: ScanResult

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: scan.detectedType.icon)
                .foregroundStyle(scan.detectedType.color)
                .frame(width: 36, height: 36)
                .background(scan.detectedType.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(scan.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(scan.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Text(scan.scannedAt, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(AppConstants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct GeneratedQRRow: View {
    let code: QRCodeItem

    var body: some View {
        HStack(spacing: 12) {
            if let data = code.imageData, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Image(systemName: code.type.icon)
                    .foregroundStyle(code.type.color)
                    .frame(width: 40, height: 40)
                    .background(code.type.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(code.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(code.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(12)
        .background(AppConstants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
