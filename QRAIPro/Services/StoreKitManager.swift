// StoreKitManager.swift
// QRAI Pro
// StoreKit 2 implementation for in-app purchases

import Foundation
import StoreKit

enum QRAIProductID: String, CaseIterable {
    case weekly = "com.appfactory.qraipro.premium.weekly"
    case monthly = "com.appfactory.qraipro.premium.monthly"
    case yearly = "com.appfactory.qraipro.premium.yearly"
    case lifetime = "com.appfactory.qraipro.premium.lifetime"

    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    static var allIDs: [String] { allCases.map { $0.rawValue } }
}

enum PurchaseState: Equatable {
    case idle
    case loading
    case purchasing
    case purchased
    case failed(String)
    case pending
    case cancelled
}

enum QRAIStoreKitError: LocalizedError {
    case productNotFound
    case purchaseFailed(Error)
    case verificationFailed
    case userCancelled
    case pending
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Product not found."
        case .purchaseFailed(let e): return "Purchase failed: \(e.localizedDescription)"
        case .verificationFailed: return "Purchase verification failed."
        case .userCancelled: return "Purchase cancelled."
        case .pending: return "Purchase is pending."
        case .unknown: return "An unknown error occurred."
        }
    }
}

@MainActor
@Observable
final class StoreKitManager {
    private(set) var subscriptions: [Product] = []
    private(set) var nonConsumables: [Product] = []
    private(set) var allProducts: [Product] = []
    private(set) var purchaseState: PurchaseState = .idle
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var purchasedSubscriptions: Set<String> = []
    private(set) var purchasedNonConsumables: Set<String> = []
    private var updateListenerTask: Task<Void, Error>?

    var hasActiveSubscription: Bool { !purchasedSubscriptions.isEmpty }
    var isPremium: Bool { hasActiveSubscription || !purchasedNonConsumables.isEmpty }
    var currentSubscriptionProductID: String? { purchasedSubscriptions.first }

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        do {
            let storeProducts = try await Product.products(for: QRAIProductID.allIDs)
            var subs: [Product] = []
            var nonCons: [Product] = []
            for product in storeProducts {
                switch product.type {
                case .autoRenewable, .nonRenewable: subs.append(product)
                case .nonConsumable: nonCons.append(product)
                default: break
                }
            }
            subscriptions = subs.sorted { $0.price < $1.price }
            nonConsumables = nonCons
            allProducts = subscriptions + nonConsumables
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        purchaseState = .purchasing
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                purchaseState = .purchased
                return transaction
            case .userCancelled:
                purchaseState = .cancelled
                throw QRAIStoreKitError.userCancelled
            case .pending:
                purchaseState = .pending
                throw QRAIStoreKitError.pending
            @unknown default:
                purchaseState = .failed("Unknown result")
                throw QRAIStoreKitError.unknown
            }
        } catch QRAIStoreKitError.userCancelled {
            purchaseState = .cancelled
            throw QRAIStoreKitError.userCancelled
        } catch {
            purchaseState = .failed(error.localizedDescription)
            errorMessage = error.localizedDescription
            throw QRAIStoreKitError.purchaseFailed(error)
        }
    }

    func restorePurchases() async {
        purchaseState = .loading
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            purchaseState = isPremium ? .purchased : .idle
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
            purchaseState = .failed(errorMessage ?? "")
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw QRAIStoreKitError.verificationFailed
        case .verified(let safe): return safe
        }
    }

    func updatePurchasedProducts() async {
        var subs: Set<String> = []
        var nonCons: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if transaction.revocationDate != nil { continue }
            switch transaction.productType {
            case .autoRenewable, .nonRenewable: subs.insert(transaction.productID)
            case .nonConsumable: nonCons.insert(transaction.productID)
            default: break
            }
        }
        purchasedSubscriptions = subs
        purchasedNonConsumables = nonCons
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let transaction = try? self?.checkVerified(result) else { continue }
                await self?.updatePurchasedProducts()
                await transaction.finish()
            }
        }
    }

    func product(for id: QRAIProductID) -> Product? {
        allProducts.first { $0.id == id.rawValue }
    }

    func resetState() {
        purchaseState = .idle
        errorMessage = nil
    }

    func pricePerPeriod(for product: Product) -> String? {
        guard let sub = product.subscription else { return nil }
        switch sub.subscriptionPeriod.unit {
        case .day: return sub.subscriptionPeriod.value == 7 ? "/week" : "/day"
        case .week: return "/week"
        case .month: return "/month"
        case .year: return "/year"
        @unknown default: return nil
        }
    }
}

extension Product {
    var periodLabel: String {
        guard let sub = subscription else { return "One-time" }
        switch sub.subscriptionPeriod.unit {
        case .day: return sub.subscriptionPeriod.value == 7 ? "per week" : "per day"
        case .week: return "per week"
        case .month: return "per month"
        case .year: return "per year"
        @unknown default: return ""
        }
    }

    var isPopular: Bool {
        subscription?.subscriptionPeriod.unit == .year
    }

    var savingsLabel: String? {
        guard let sub = subscription else { return nil }
        return sub.subscriptionPeriod.unit == .year ? "Best Value" : nil
    }
}
