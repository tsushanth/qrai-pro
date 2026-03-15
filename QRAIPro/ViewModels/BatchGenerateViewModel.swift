// BatchGenerateViewModel.swift
// QRAI Pro

import Foundation
import SwiftUI
import SwiftData

struct BatchQRItem: Identifiable {
    let id = UUID()
    var content: String
    var title: String
    var qrType: QRType
    var generatedImage: UIImage?
    var status: BatchItemStatus
}

enum BatchItemStatus {
    case pending, generating, done, failed
}

@MainActor
@Observable
final class BatchGenerateViewModel {
    var items: [BatchQRItem] = []
    var style: QRStyle = .defaultStyle
    var isGenerating = false
    var progress: Double = 0
    var newItemContent: String = ""
    var newItemTitle: String = ""
    var newItemType: QRType = .url
    var showAddItem = false
    var generatedImages: [UIImage] = []
    var showExportSheet = false
    var errorMessage: String?

    private let generator = QRGeneratorService.shared

    var canGenerate: Bool { !items.isEmpty }
    var completedCount: Int { items.filter { $0.status == .done }.count }

    func addItem() {
        guard !newItemContent.isEmpty else { return }
        let item = BatchQRItem(
            content: newItemType.encode(content: newItemContent),
            title: newItemTitle.isEmpty ? newItemType.displayName : newItemTitle,
            qrType: newItemType,
            status: .pending
        )
        items.append(item)
        newItemContent = ""
        newItemTitle = ""
        showAddItem = false
        HapticsManager.shared.impact(.light)
    }

    func removeItem(at index: Int) {
        guard index < items.count else { return }
        items.remove(at: index)
    }

    func generateAll() async {
        guard canGenerate else { return }
        isGenerating = true
        progress = 0
        generatedImages = []
        AnalyticsService.shared.track(.batchGenerateStarted)

        for i in 0..<items.count {
            items[i].status = .generating
            let image = generator.generateQRCode(from: items[i].content, style: style)
            items[i].generatedImage = image
            items[i].status = image != nil ? .done : .failed
            if let img = image { generatedImages.append(img) }
            progress = Double(i + 1) / Double(items.count)
        }

        isGenerating = false
        AnalyticsService.shared.track(.batchGenerateCompleted(count: generatedImages.count))
        HapticsManager.shared.success()
    }

    func saveAll(to modelContext: ModelContext) {
        for item in items where item.status == .done {
            let styleData = try? JSONEncoder().encode(style)
            let imageData = item.generatedImage?.pngData()
            let qrCode = QRCodeItem(
                title: item.title,
                content: item.content,
                qrType: item.qrType,
                styleData: styleData,
                imageData: imageData
            )
            HistoryService.shared.addQRCode(qrCode, to: modelContext)
        }
        HapticsManager.shared.success()
    }

    func clearAll() {
        items = []
        generatedImages = []
        progress = 0
    }
}
