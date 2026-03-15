// SettingsView.swift
// QRAI Pro

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(PremiumManager.self) private var premiumManager
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                // Premium Section
                if !premiumManager.isPremium {
                    Section {
                        Button(action: { showPaywall = true }) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AppConstants.Colors.gradient)
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "crown.fill")
                                        .foregroundStyle(.white)
                                        .font(.caption)
                                }
                                VStack(alignment: .leading) {
                                    Text("Upgrade to Pro")
                                        .font(.headline)
                                    Text("Unlock all features")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    Section {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(AppConstants.Colors.qrBlue)
                            Text("QRAI Pro Premium")
                                .font(.headline)
                            Spacer()
                            Text("Active")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppConstants.Colors.qrGreen.opacity(0.15))
                                .foregroundStyle(AppConstants.Colors.qrGreen)
                                .clipShape(Capsule())
                        }
                    }
                }

                // Stats
                Section("Usage") {
                    statRow("Total Scans", value: "\(HistoryService.shared.totalScanCount)")
                    statRow("QR Codes Created", value: "\(HistoryService.shared.totalGenerateCount)")
                }

                // App
                Section("App") {
                    Link(destination: URL(string: "https://apps.apple.com")!) {
                        Label("Rate QRAI Pro", systemImage: "star")
                    }
                    Link(destination: URL(string: "https://appfactory.app/support")!) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    Link(destination: URL(string: "https://appfactory.app/privacy")!) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                    Link(destination: URL(string: "https://appfactory.app/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }

                // Premium actions
                Section("Account") {
                    Button(action: {
                        Task { await premiumManager.restorePurchases() }
                    }) {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }

                    if premiumManager.isPremium {
                        Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                            Label("Manage Subscription", systemImage: "creditcard")
                        }
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            AnalyticsService.shared.track(.settingsOpened)
        }
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        }
    }
}
