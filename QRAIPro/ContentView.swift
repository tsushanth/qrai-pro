// ContentView.swift
// QRAI Pro

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(PremiumManager.self) private var premiumManager
    @Environment(DeepLinkManager.self) private var deepLinkManager
    @AppStorage(AppConstants.Keys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                mainTabView
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            ScannerView()
                .tabItem {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
                .tag(0)

            GenerateView()
                .tabItem {
                    Label("Generate", systemImage: "qrcode")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
        .tint(AppConstants.Colors.qrBlue)
        .onChange(of: deepLinkManager.selectedTab) { _, newTab in
            selectedTab = newTab
        }
    }
}
