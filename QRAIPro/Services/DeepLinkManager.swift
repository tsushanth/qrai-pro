// DeepLinkManager.swift
// QRAI Pro

import Foundation
import SwiftUI

enum DeepLink {
    case scan
    case generate(type: QRType?)
    case history
    case settings
    case paywall

    static func from(url: URL) -> DeepLink? {
        guard url.scheme == AppConstants.deepLinkScheme else { return nil }
        switch url.host {
        case "scan": return .scan
        case "generate":
            let typeParam = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "type" })?.value
            let qrType = typeParam.flatMap { QRType(rawValue: $0) }
            return .generate(type: qrType)
        case "history": return .history
        case "settings": return .settings
        case "paywall": return .paywall
        default: return nil
        }
    }
}

@MainActor
@Observable
final class DeepLinkManager {
    var pendingDeepLink: DeepLink?
    var selectedTab: Int = 0

    func handle(url: URL) {
        guard let deepLink = DeepLink.from(url: url) else { return }
        pendingDeepLink = deepLink
        AnalyticsService.shared.track(.deepLinkOpened(scheme: url.absoluteString))

        switch deepLink {
        case .scan: selectedTab = 0
        case .generate: selectedTab = 1
        case .history: selectedTab = 2
        case .settings: selectedTab = 3
        case .paywall: break
        }
    }

    func consumeDeepLink() -> DeepLink? {
        defer { pendingDeepLink = nil }
        return pendingDeepLink
    }
}
