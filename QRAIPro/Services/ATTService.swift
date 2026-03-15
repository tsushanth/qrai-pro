// ATTService.swift
// QRAI Pro

import Foundation
import AppTrackingTransparency
import AdServices

@MainActor
final class ATTService {
    static let shared = ATTService()
    private init() {}

    var trackingStatus: ATTrackingManager.AuthorizationStatus {
        ATTrackingManager.trackingAuthorizationStatus
    }

    func requestIfNeeded() async -> ATTrackingManager.AuthorizationStatus {
        let status = ATTrackingManager.trackingAuthorizationStatus
        guard status == .notDetermined else { return status }

        // Small delay to allow UI to settle
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        let result = await ATTrackingManager.requestTrackingAuthorization()
        #if DEBUG
        print("[ATT] Status: \(result.rawValue)")
        #endif
        return result
    }
}
