// GenerateViewModel.swift
// QRAI Pro

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class GenerateViewModel {
    // Input
    var selectedType: QRType = .url
    var content: String = ""
    var title: String = ""
    var style: QRStyle = .defaultStyle

    // WiFi specific
    var wifiSSID: String = ""
    var wifiPassword: String = ""
    var wifiSecurity: String = "WPA"
    var wifiHidden: Bool = false

    // Contact specific
    var contactFirstName: String = ""
    var contactLastName: String = ""
    var contactPhone: String = ""
    var contactEmail: String = ""
    var contactOrg: String = ""
    var contactURL: String = ""

    // Location specific
    var latitude: String = ""
    var longitude: String = ""
    var locationLabel: String = ""

    // State
    var generatedImage: UIImage?
    var generatedSVG: String = ""
    var isGenerating = false
    var showStyleEditor = false
    var showPaywall = false
    var showExportSheet = false
    var errorMessage: String?
    var showSavedAlert = false

    private let generator = QRGeneratorService.shared

    // MARK: - Computed Content

    var encodedContent: String {
        switch selectedType {
        case .wifi:
            return "WIFI:T:\(wifiSecurity);S:\(wifiSSID);P:\(wifiPassword);\(wifiHidden ? "H:true;" : "");"
        case .contact:
            return """
            BEGIN:VCARD
            VERSION:3.0
            N:\(contactLastName);\(contactFirstName);;;
            FN:\(contactFirstName) \(contactLastName)
            ORG:\(contactOrg)
            TEL:\(contactPhone)
            EMAIL:\(contactEmail)
            URL:\(contactURL)
            END:VCARD
            """
        case .location:
            return "geo:\(latitude),\(longitude)"
        default:
            return selectedType.encode(content: content)
        }
    }

    var isContentValid: Bool {
        switch selectedType {
        case .wifi: return !wifiSSID.isEmpty
        case .contact: return !contactFirstName.isEmpty || !contactLastName.isEmpty
        case .location: return !latitude.isEmpty && !longitude.isEmpty
        default: return !content.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    // MARK: - Generate

    func generateQRCode(isPremium: Bool) {
        guard isContentValid else {
            errorMessage = "Please enter the required information."
            return
        }

        if selectedType.isPremium && !isPremium {
            showPaywall = true
            return
        }

        isGenerating = true
        errorMessage = nil

        let contentToEncode = encodedContent
        let currentStyle = style

        Task {
            let image = generator.generateQRCode(from: contentToEncode, style: currentStyle)
            let svg = generator.generateSVG(from: contentToEncode, style: currentStyle)
            generatedImage = image
            generatedSVG = svg
            isGenerating = false
            AnalyticsService.shared.track(.generateCompleted(type: selectedType.rawValue))
        }
    }

    func saveQRCode(to modelContext: ModelContext) {
        guard let image = generatedImage else { return }

        let styleData = try? JSONEncoder().encode(style)
        let imageData = image.pngData()
        let qrTitle = title.isEmpty ? selectedType.displayName : title

        let item = QRCodeItem(
            title: qrTitle,
            content: encodedContent,
            qrType: selectedType,
            styleData: styleData,
            imageData: imageData
        )

        HistoryService.shared.addQRCode(item, to: modelContext)
        showSavedAlert = true
        AnalyticsService.shared.track(.generateCompleted(type: selectedType.rawValue))
    }

    func resetForm() {
        content = ""
        title = ""
        wifiSSID = ""
        wifiPassword = ""
        contactFirstName = ""
        contactLastName = ""
        contactPhone = ""
        contactEmail = ""
        latitude = ""
        longitude = ""
        generatedImage = nil
        generatedSVG = ""
        errorMessage = nil
    }

    func selectType(_ type: QRType, isPremium: Bool) {
        if type.isPremium && !isPremium {
            showPaywall = true
            return
        }
        selectedType = type
        resetForm()
        AnalyticsService.shared.track(.generateStarted(type: type.rawValue))
    }
}
