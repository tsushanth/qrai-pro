// ExportService.swift
// QRAI Pro

import Foundation
import UIKit
import SwiftUI

enum ExportFormat: String, CaseIterable {
    case png = "PNG"
    case svg = "SVG"
    case jpeg = "JPEG"
    case pdf = "PDF"

    var isPremium: Bool {
        switch self {
        case .png: return false
        case .svg, .jpeg, .pdf: return true
        }
    }

    var fileExtension: String { rawValue.lowercased() }
    var mimeType: String {
        switch self {
        case .png: return "image/png"
        case .jpeg: return "image/jpeg"
        case .svg: return "image/svg+xml"
        case .pdf: return "application/pdf"
        }
    }
}

@MainActor
final class ExportService {
    static let shared = ExportService()
    private init() {}

    func exportAsPNG(_ image: UIImage, filename: String = "qrcode") -> URL? {
        guard let data = image.pngData() else { return nil }
        return saveToTemp(data: data, filename: "\(filename).png")
    }

    func exportAsJPEG(_ image: UIImage, filename: String = "qrcode", quality: CGFloat = 0.9) -> URL? {
        guard let data = image.jpegData(compressionQuality: quality) else { return nil }
        return saveToTemp(data: data, filename: "\(filename).jpg")
    }

    func exportAsSVG(_ svgString: String, filename: String = "qrcode") -> URL? {
        guard let data = svgString.data(using: .utf8) else { return nil }
        return saveToTemp(data: data, filename: "\(filename).svg")
    }

    func exportAsPDF(_ image: UIImage, filename: String = "qrcode") -> URL? {
        let pageRect = CGRect(x: 0, y: 0, width: 300, height: 300)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            image.draw(in: pageRect)
        }
        return saveToTemp(data: data, filename: "\(filename).pdf")
    }

    private func saveToTemp(data: Data, filename: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url
        } catch {
            print("[Export] Failed: \(error)")
            return nil
        }
    }

    func share(image: UIImage, from viewController: UIViewController? = nil) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, from: viewController)
    }

    func share(url: URL, from viewController: UIViewController? = nil) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, from: viewController)
    }

    private func present(_ vc: UIViewController, from parent: UIViewController?) {
        let presenter = parent ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController
        presenter?.present(vc, animated: true)
    }

    // MARK: - Batch Export

    func batchExportAsPNG(_ images: [UIImage], zipFilename: String = "qrcodes") -> URL? {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(zipFilename)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        for (i, image) in images.enumerated() {
            if let data = image.pngData() {
                let fileURL = tempDir.appendingPathComponent("qrcode_\(i + 1).png")
                try? data.write(to: fileURL)
            }
        }
        return tempDir
    }
}
