// HistoryService.swift
// QRAI Pro

import Foundation
import SwiftData

@MainActor
final class HistoryService {
    static let shared = HistoryService()
    private init() {}

    func addScanResult(_ result: ScanResult, to context: ModelContext) {
        context.insert(result)
        try? context.save()
        incrementScanCount()
    }

    func addQRCode(_ code: QRCodeItem, to context: ModelContext) {
        context.insert(code)
        try? context.save()
        incrementGenerateCount()
    }

    func deleteScanResult(_ result: ScanResult, from context: ModelContext) {
        context.delete(result)
        try? context.save()
    }

    func deleteQRCode(_ code: QRCodeItem, from context: ModelContext) {
        context.delete(code)
        try? context.save()
    }

    func toggleFavoriteScan(_ result: ScanResult, in context: ModelContext) {
        result.isFavorite.toggle()
        try? context.save()
    }

    func toggleFavoriteQR(_ code: QRCodeItem, in context: ModelContext) {
        code.isFavorite.toggle()
        try? context.save()
    }

    func clearAllScans(from context: ModelContext) {
        let descriptor = FetchDescriptor<ScanResult>()
        if let results = try? context.fetch(descriptor) {
            results.forEach { context.delete($0) }
            try? context.save()
        }
    }

    func clearAllQRCodes(from context: ModelContext) {
        let descriptor = FetchDescriptor<QRCodeItem>()
        if let codes = try? context.fetch(descriptor) {
            codes.forEach { context.delete($0) }
            try? context.save()
        }
    }

    // MARK: - Counters

    private func incrementScanCount() {
        let count = UserDefaults.standard.integer(forKey: AppConstants.Keys.scanCount)
        UserDefaults.standard.set(count + 1, forKey: AppConstants.Keys.scanCount)
    }

    private func incrementGenerateCount() {
        let count = UserDefaults.standard.integer(forKey: AppConstants.Keys.generateCount)
        UserDefaults.standard.set(count + 1, forKey: AppConstants.Keys.generateCount)
    }

    var totalScanCount: Int {
        UserDefaults.standard.integer(forKey: AppConstants.Keys.scanCount)
    }

    var totalGenerateCount: Int {
        UserDefaults.standard.integer(forKey: AppConstants.Keys.generateCount)
    }
}
