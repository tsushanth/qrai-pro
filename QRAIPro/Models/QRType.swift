// QRType.swift
// QRAI Pro

import Foundation
import SwiftUI

enum QRType: String, CaseIterable, Codable, Identifiable {
    case url = "URL"
    case text = "Text"
    case contact = "Contact"
    case wifi = "WiFi"
    case email = "Email"
    case sms = "SMS"
    case phone = "Phone"
    case location = "Location"
    case instagram = "Instagram"
    case twitter = "Twitter"
    case facebook = "Facebook"
    case linkedin = "LinkedIn"
    case youtube = "YouTube"
    case tiktok = "TikTok"
    case barcode = "Barcode"
    case whatsapp = "WhatsApp"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .url: return "link"
        case .text: return "doc.text"
        case .contact: return "person.crop.circle"
        case .wifi: return "wifi"
        case .email: return "envelope"
        case .sms: return "message"
        case .phone: return "phone"
        case .location: return "mappin.circle"
        case .instagram: return "camera"
        case .twitter: return "bird"
        case .facebook: return "person.2"
        case .linkedin: return "briefcase"
        case .youtube: return "play.rectangle"
        case .tiktok: return "music.note"
        case .barcode: return "barcode"
        case .whatsapp: return "bubble.left.and.bubble.right"
        }
    }

    var color: Color {
        switch self {
        case .url: return AppConstants.Colors.qrBlue
        case .text: return Color.gray
        case .contact: return Color.teal
        case .wifi: return AppConstants.Colors.qrBlue
        case .email: return Color.red
        case .sms: return AppConstants.Colors.qrGreen
        case .phone: return AppConstants.Colors.qrGreen
        case .location: return Color.orange
        case .instagram: return Color(red: 0.83, green: 0.18, blue: 0.53)
        case .twitter: return Color(red: 0.11, green: 0.63, blue: 0.95)
        case .facebook: return Color(red: 0.23, green: 0.35, blue: 0.60)
        case .linkedin: return Color(red: 0.0, green: 0.47, blue: 0.71)
        case .youtube: return Color.red
        case .tiktok: return Color.black
        case .barcode: return Color.brown
        case .whatsapp: return Color(red: 0.07, green: 0.73, blue: 0.36)
        }
    }

    var displayName: String { rawValue }

    var isPremium: Bool {
        switch self {
        case .instagram, .twitter, .facebook, .linkedin, .youtube, .tiktok, .whatsapp:
            return true
        default:
            return false
        }
    }

    var placeholder: String {
        switch self {
        case .url: return "https://example.com"
        case .text: return "Enter your text here..."
        case .contact: return "Contact details"
        case .wifi: return "Network name"
        case .email: return "email@example.com"
        case .sms: return "+1234567890"
        case .phone: return "+1234567890"
        case .location: return "40.7128, -74.0060"
        case .instagram: return "@username"
        case .twitter: return "@username"
        case .facebook: return "facebook.com/username"
        case .linkedin: return "linkedin.com/in/username"
        case .youtube: return "youtube.com/channel/..."
        case .tiktok: return "@username"
        case .barcode: return "12345678"
        case .whatsapp: return "+1234567890"
        }
    }

    func encode(content: String) -> String {
        switch self {
        case .url: return content.hasPrefix("http") ? content : "https://\(content)"
        case .text: return content
        case .email: return "mailto:\(content)"
        case .sms: return "sms:\(content)"
        case .phone: return "tel:\(content)"
        case .instagram: return "https://instagram.com/\(content.trimmingCharacters(in: CharacterSet(charactersIn: "@")))"
        case .twitter: return "https://twitter.com/\(content.trimmingCharacters(in: CharacterSet(charactersIn: "@")))"
        case .facebook: return content.hasPrefix("http") ? content : "https://\(content)"
        case .linkedin: return content.hasPrefix("http") ? content : "https://\(content)"
        case .youtube: return content.hasPrefix("http") ? content : "https://\(content)"
        case .tiktok: return "https://tiktok.com/@\(content.trimmingCharacters(in: CharacterSet(charactersIn: "@")))"
        case .whatsapp: return "https://wa.me/\(content.filter { $0.isNumber })"
        case .contact, .wifi, .location, .barcode: return content
        }
    }
}
