// AnalyticsService.swift
// QRAI Pro

import Foundation

enum AnalyticsEvent {
    case appOpen
    case screenView(name: String)
    case scanStarted
    case scanCompleted(type: String)
    case generateStarted(type: String)
    case generateCompleted(type: String)
    case paywallShown(source: String)
    case purchaseStarted(productID: String)
    case purchaseCompleted(productID: String)
    case purchaseFailed(reason: String)
    case shareQR(type: String)
    case exportQR(format: String)
    case batchGenerateStarted
    case batchGenerateCompleted(count: Int)
    case onboardingCompleted
    case settingsOpened
    case historyViewed
    case favoriteAdded
    case deepLinkOpened(scheme: String)

    var name: String {
        switch self {
        case .appOpen: return "app_open"
        case .screenView(let name): return "screen_view_\(name)"
        case .scanStarted: return "scan_started"
        case .scanCompleted(let type): return "scan_completed_\(type)"
        case .generateStarted(let type): return "generate_started_\(type)"
        case .generateCompleted(let type): return "generate_completed_\(type)"
        case .paywallShown(let source): return "paywall_shown_\(source)"
        case .purchaseStarted(let id): return "purchase_started_\(id)"
        case .purchaseCompleted(let id): return "purchase_completed_\(id)"
        case .purchaseFailed(let reason): return "purchase_failed_\(reason)"
        case .shareQR(let type): return "share_qr_\(type)"
        case .exportQR(let format): return "export_qr_\(format)"
        case .batchGenerateStarted: return "batch_generate_started"
        case .batchGenerateCompleted(let count): return "batch_generate_completed_\(count)"
        case .onboardingCompleted: return "onboarding_completed"
        case .settingsOpened: return "settings_opened"
        case .historyViewed: return "history_viewed"
        case .favoriteAdded: return "favorite_added"
        case .deepLinkOpened(let scheme): return "deep_link_opened_\(scheme)"
        }
    }
}

@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()
    private var isInitialized = false

    private init() {}

    func initialize() {
        guard !isInitialized else { return }
        isInitialized = true
        // Firebase Analytics initialization would go here
        // FirebaseApp.configure()
        #if DEBUG
        print("[Analytics] Initialized")
        #endif
    }

    func track(_ event: AnalyticsEvent) {
        guard isInitialized else { return }
        #if DEBUG
        print("[Analytics] Event: \(event.name)")
        #endif
        // Firebase: Analytics.logEvent(event.name, parameters: nil)
        // Facebook: AppEvents.logEvent(AppEvents.Name(event.name))
    }

    func setUserProperty(_ value: String?, forName name: String) {
        #if DEBUG
        print("[Analytics] Set property \(name): \(value ?? "nil")")
        #endif
        // Analytics.setUserProperty(value, forName: name)
    }
}
