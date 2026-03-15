// HapticsManager.swift
// QRAI Pro

import Foundation
import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    private init() {}

    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
