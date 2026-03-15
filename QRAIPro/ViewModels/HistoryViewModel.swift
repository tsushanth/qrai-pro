// HistoryViewModel.swift
// QRAI Pro

import Foundation
import SwiftUI
import SwiftData

enum HistoryTab: String, CaseIterable {
    case scanned = "Scanned"
    case generated = "Generated"

    var icon: String {
        switch self {
        case .scanned: return "qrcode.viewfinder"
        case .generated: return "qrcode"
        }
    }
}

@MainActor
@Observable
final class HistoryViewModel {
    var selectedTab: HistoryTab = .scanned
    var searchText: String = ""
    var showFavoritesOnly = false
    var selectedScanResult: ScanResult?
    var selectedQRCode: QRCodeItem?
    var showDeleteConfirmation = false

    func filteredScans(_ scans: [ScanResult]) -> [ScanResult] {
        var filtered = scans
        if showFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        return filtered.sorted { $0.scannedAt > $1.scannedAt }
    }

    func filteredCodes(_ codes: [QRCodeItem]) -> [QRCodeItem] {
        var filtered = codes
        if showFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }

    func deleteScan(_ result: ScanResult, from modelContext: ModelContext) {
        HistoryService.shared.deleteScanResult(result, from: modelContext)
    }

    func deleteQRCode(_ code: QRCodeItem, from modelContext: ModelContext) {
        HistoryService.shared.deleteQRCode(code, from: modelContext)
    }

    func toggleFavorite(scan: ScanResult, in modelContext: ModelContext) {
        HistoryService.shared.toggleFavoriteScan(scan, in: modelContext)
        HapticsManager.shared.impact(.light)
        if scan.isFavorite {
            AnalyticsService.shared.track(.favoriteAdded)
        }
    }

    func toggleFavorite(code: QRCodeItem, in modelContext: ModelContext) {
        HistoryService.shared.toggleFavoriteQR(code, in: modelContext)
        HapticsManager.shared.impact(.light)
    }
}
