// ScanResult.swift
// QRAI Pro

import Foundation
import SwiftData

@Model
final class ScanResult {
    var id: UUID
    var rawValue: String
    var codeType: String
    var scannedAt: Date
    var isFavorite: Bool
    var title: String
    var note: String
    var thumbnailData: Data?

    init(
        id: UUID = UUID(),
        rawValue: String,
        codeType: String = "QR",
        title: String = ""
    ) {
        self.id = id
        self.rawValue = rawValue
        self.codeType = codeType
        self.scannedAt = Date()
        self.isFavorite = false
        self.title = title.isEmpty ? Self.generateTitle(from: rawValue) : title
        self.note = ""
        self.thumbnailData = nil
    }

    var detectedType: QRType {
        if rawValue.hasPrefix("http://") || rawValue.hasPrefix("https://") { return .url }
        if rawValue.hasPrefix("mailto:") { return .email }
        if rawValue.hasPrefix("tel:") { return .phone }
        if rawValue.hasPrefix("sms:") { return .sms }
        if rawValue.hasPrefix("WIFI:") { return .wifi }
        if rawValue.hasPrefix("BEGIN:VCARD") { return .contact }
        if rawValue.hasPrefix("geo:") { return .location }
        if rawValue.contains("instagram.com") { return .instagram }
        if rawValue.contains("twitter.com") || rawValue.contains("x.com") { return .twitter }
        if rawValue.contains("facebook.com") { return .facebook }
        if rawValue.contains("linkedin.com") { return .linkedin }
        if rawValue.contains("youtube.com") || rawValue.contains("youtu.be") { return .youtube }
        if rawValue.contains("tiktok.com") { return .tiktok }
        if rawValue.contains("wa.me") || rawValue.contains("whatsapp.com") { return .whatsapp }
        return .text
    }

    var displayValue: String {
        let type = detectedType
        switch type {
        case .email: return rawValue.replacingOccurrences(of: "mailto:", with: "")
        case .phone: return rawValue.replacingOccurrences(of: "tel:", with: "")
        case .sms: return rawValue.replacingOccurrences(of: "sms:", with: "")
        default: return rawValue
        }
    }

    var isURL: Bool {
        detectedType == .url || rawValue.hasPrefix("http")
    }

    static func generateTitle(from value: String) -> String {
        if value.hasPrefix("http://") || value.hasPrefix("https://") {
            if let host = URL(string: value)?.host {
                return host
            }
        }
        if value.hasPrefix("mailto:") { return "Email" }
        if value.hasPrefix("tel:") { return "Phone Number" }
        if value.hasPrefix("sms:") { return "SMS" }
        if value.hasPrefix("WIFI:") { return "WiFi Network" }
        if value.hasPrefix("BEGIN:VCARD") { return "Contact" }
        if value.hasPrefix("geo:") { return "Location" }
        let truncated = String(value.prefix(30))
        return truncated + (value.count > 30 ? "..." : "")
    }
}
