// AppConstants.swift
// QRAI Pro

import Foundation
import SwiftUI

enum AppConstants {
    static let bundleID = "com.appfactory.qraipro"
    static let appName = "QRAI Pro"
    static let appVersion = "1.0.0"

    // RevenueCat
    static let revenueCatAPIKey = "appl_PLACEHOLDER_KEY"

    // Product IDs
    enum ProductID {
        static let weekly = "com.appfactory.qraipro.premium.weekly"
        static let monthly = "com.appfactory.qraipro.premium.monthly"
        static let yearly = "com.appfactory.qraipro.premium.yearly"
        static let lifetime = "com.appfactory.qraipro.premium.lifetime"
        static let all = [weekly, monthly, yearly, lifetime]
    }

    // Colors
    enum Colors {
        static let primary = Color("AccentColor")
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let label = Color(.label)
        static let secondaryLabel = Color(.secondaryLabel)
        static let qrBlue = Color(red: 0.18, green: 0.45, blue: 0.95)
        static let qrPurple = Color(red: 0.55, green: 0.25, blue: 0.92)
        static let qrGreen = Color(red: 0.18, green: 0.78, blue: 0.48)
        static let qrOrange = Color(red: 1.0, green: 0.55, blue: 0.10)
        static let gradient = LinearGradient(
            colors: [Color(red: 0.18, green: 0.45, blue: 0.95), Color(red: 0.55, green: 0.25, blue: 0.92)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Deep Link Scheme
    static let deepLinkScheme = "qraipro"

    // UserDefaults Keys
    enum Keys {
        static let hasCompletedOnboarding = "com.appfactory.qraipro.hasCompletedOnboarding"
        static let isPremium = "com.appfactory.qraipro.isPremium"
        static let scanCount = "com.appfactory.qraipro.scanCount"
        static let generateCount = "com.appfactory.qraipro.generateCount"
        static let appLaunchCount = "com.appfactory.qraipro.appLaunchCount"
        static let lastReviewRequestDate = "com.appfactory.qraipro.lastReviewRequestDate"
        static let selectedTab = "com.appfactory.qraipro.selectedTab"
    }

    // Free tier limits
    enum FreeTier {
        static let maxScansPerDay = 10
        static let maxGenerationsPerDay = 5
        static let maxHistoryItems = 20
    }
}
