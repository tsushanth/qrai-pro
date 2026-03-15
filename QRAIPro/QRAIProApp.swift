// QRAIProApp.swift
// QRAI Pro
// Main app entry point

import SwiftUI
import SwiftData

@main
struct QRAIProApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let modelContainer: ModelContainer
    @State private var premiumManager = PremiumManager(storeKitManager: StoreKitManager())
    @State private var deepLinkManager = DeepLinkManager()

    init() {
        do {
            let schema = Schema([
                QRCodeItem.self,
                ScanResult.self,
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        ReviewManager.shared.recordAppLaunch()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(premiumManager)
                .environment(deepLinkManager)
                .onAppear {
                    Task {
                        await premiumManager.refreshPremiumStatus()
                    }
                }
                .onOpenURL { url in
                    deepLinkManager.handle(url: url)
                }
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Task { @MainActor in
            AnalyticsService.shared.initialize()
            AnalyticsService.shared.track(.appOpen)
        }

        Task { @MainActor in
            _ = await ATTService.shared.requestIfNeeded()
            await AttributionManager.shared.requestAttributionIfNeeded()
        }

        return true
    }
}
