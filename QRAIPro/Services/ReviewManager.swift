// ReviewManager.swift
// QRAI Pro

import Foundation
import StoreKit

@MainActor
final class ReviewManager {
    static let shared = ReviewManager()
    private init() {}

    private let launchCountKey = AppConstants.Keys.appLaunchCount
    private let lastReviewKey = AppConstants.Keys.lastReviewRequestDate
    private let minLaunchesBeforeReview = 5
    private let minDaysBetweenReviews = 30

    func recordAppLaunch() {
        let count = UserDefaults.standard.integer(forKey: launchCountKey)
        UserDefaults.standard.set(count + 1, forKey: launchCountKey)
    }

    func requestReviewIfAppropriate() {
        let launchCount = UserDefaults.standard.integer(forKey: launchCountKey)
        guard launchCount >= minLaunchesBeforeReview else { return }

        if let lastDate = UserDefaults.standard.object(forKey: lastReviewKey) as? Date {
            let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            guard daysSince >= minDaysBetweenReviews else { return }
        }

        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            UserDefaults.standard.set(Date(), forKey: lastReviewKey)
        }
    }
}
