// QRCode.swift
// QRAI Pro

import Foundation
import SwiftData

@Model
final class QRCodeItem {
    var id: UUID
    var title: String
    var content: String
    var qrType: String
    var createdAt: Date
    var updatedAt: Date
    var styleData: Data?
    var imageData: Data?
    var isFavorite: Bool
    var tags: [String]
    var scanCount: Int
    var shareCount: Int

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        qrType: QRType,
        styleData: Data? = nil,
        imageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.qrType = qrType.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
        self.styleData = styleData
        self.imageData = imageData
        self.isFavorite = false
        self.tags = []
        self.scanCount = 0
        self.shareCount = 0
    }

    var type: QRType {
        QRType(rawValue: qrType) ?? .text
    }

    var style: QRStyle? {
        guard let data = styleData else { return nil }
        return try? JSONDecoder().decode(QRStyle.self, from: data)
    }
}
