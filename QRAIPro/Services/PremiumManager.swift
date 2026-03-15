// PremiumManager.swift
// QRAI Pro

import Foundation
import StoreKit

@MainActor
@Observable
final class PremiumManager {
    var isPremium: Bool = false
    var premiumSource: String = ""

    private let storeKitManager: StoreKitManager
    private let userDefaults = UserDefaults.standard

    init(storeKitManager: StoreKitManager) {
        self.storeKitManager = storeKitManager
        isPremium = userDefaults.bool(forKey: AppConstants.Keys.isPremium)
    }

    func refreshPremiumStatus() async {
        await storeKitManager.updatePurchasedProducts()
        let newStatus = storeKitManager.isPremium
        if newStatus != isPremium {
            isPremium = newStatus
            userDefaults.set(newStatus, forKey: AppConstants.Keys.isPremium)
        }
        premiumSource = storeKitManager.currentSubscriptionProductID ?? ""
    }

    func purchaseProduct(_ product: Product) async throws {
        _ = try await storeKitManager.purchase(product)
        await refreshPremiumStatus()
    }

    func restorePurchases() async {
        await storeKitManager.restorePurchases()
        await refreshPremiumStatus()
    }

    var storeKit: StoreKitManager { storeKitManager }

    func canUsePremiumFeature() -> Bool { isPremium }
}
