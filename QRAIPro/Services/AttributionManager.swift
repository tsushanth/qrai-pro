// AttributionManager.swift
// QRAI Pro

import Foundation
import AdServices

@MainActor
final class AttributionManager {
    static let shared = AttributionManager()
    private init() {}

    func requestAttributionIfNeeded() async {
        do {
            let token = try AAAttribution.attributionToken()
            #if DEBUG
            print("[Attribution] Token: \(token.prefix(20))...")
            #endif
            // Send token to your attribution server or RevenueCat
        } catch {
            #if DEBUG
            print("[Attribution] Failed: \(error.localizedDescription)")
            #endif
        }
    }
}
