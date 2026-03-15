// QRGeneratorService.swift
// QRAI Pro

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import SwiftUI

@MainActor
final class QRGeneratorService {
    static let shared = QRGeneratorService()
    private let context = CIContext()
    private init() {}

    // MARK: - Generate QR Code Image

    func generateQRCode(from content: String, style: QRStyle = .defaultStyle, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        guard let ciImage = generateCIImage(from: content, errorCorrection: style.errorCorrection) else { return nil }

        let scaleX = size.width / ciImage.extent.size.width
        let scaleY = size.height / ciImage.extent.size.height
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // Apply colors
        guard let coloredImage = applyColors(to: scaledImage, style: style) else { return nil }

        guard let cgImage = context.createCGImage(coloredImage, from: coloredImage.extent) else { return nil }
        var result = UIImage(cgImage: cgImage)

        // Add logo if provided
        if let logoData = style.logoData, let logo = UIImage(data: logoData) {
            result = overlayLogo(logo, on: result, scale: style.logoScale)
        }

        return result
    }

    private func generateCIImage(from content: String, errorCorrection: QRErrorCorrection) -> CIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(content.utf8)
        filter.correctionLevel = errorCorrection.rawValue
        return filter.outputImage
    }

    private func applyColors(to image: CIImage, style: QRStyle) -> CIImage? {
        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = image
        colorFilter.color0 = CIColor(color: UIColor(style.backgroundSwiftUIColor))
        colorFilter.color1 = CIColor(color: UIColor(style.foregroundSwiftUIColor))
        return colorFilter.outputImage
    }

    private func overlayLogo(_ logo: UIImage, on qrImage: UIImage, scale: CGFloat) -> UIImage {
        let size = qrImage.size
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            qrImage.draw(in: CGRect(origin: .zero, size: size))
            let logoSize = CGSize(width: size.width * scale, height: size.height * scale)
            let logoOrigin = CGPoint(
                x: (size.width - logoSize.width) / 2,
                y: (size.height - logoSize.height) / 2
            )
            // White background for logo
            let paddedLogoSize = CGSize(width: logoSize.width + 10, height: logoSize.height + 10)
            let paddedOrigin = CGPoint(x: logoOrigin.x - 5, y: logoOrigin.y - 5)
            UIColor.white.setFill()
            UIBezierPath(roundedRect: CGRect(origin: paddedOrigin, size: paddedLogoSize), cornerRadius: 4).fill()
            logo.draw(in: CGRect(origin: logoOrigin, size: logoSize))
        }
    }

    // MARK: - Generate SVG

    func generateSVG(from content: String, style: QRStyle = .defaultStyle, size: Int = 300) -> String {
        guard let ciImage = generateCIImage(from: content, errorCorrection: style.errorCorrection) else { return "" }
        let extent = ciImage.extent
        let width = Int(extent.width)
        let height = Int(extent.height)

        guard let cgImage = context.createCGImage(ciImage, from: extent) else { return "" }
        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else { return "" }

        let fgColor = UIColor(style.foregroundSwiftUIColor)
        var fgR: CGFloat = 0, fgG: CGFloat = 0, fgB: CGFloat = 0, fgA: CGFloat = 0
        fgColor.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)

        let bgColor = UIColor(style.backgroundSwiftUIColor)
        var bgR: CGFloat = 0, bgG: CGFloat = 0, bgB: CGFloat = 0, bgA: CGFloat = 0
        bgColor.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)

        let fgHex = String(format: "#%02X%02X%02X", Int(fgR * 255), Int(fgG * 255), Int(fgB * 255))
        let bgHex = String(format: "#%02X%02X%02X", Int(bgR * 255), Int(bgG * 255), Int(bgB * 255))

        let scale = size / max(width, height)
        var rects = ""

        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4
                let brightness = bytes[pixelIndex]
                if brightness < 128 {
                    rects += "<rect x=\"\(x * scale)\" y=\"\(y * scale)\" width=\"\(scale)\" height=\"\(scale)\" fill=\"\(fgHex)\"/>"
                }
            }
        }

        return """
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 \(width * scale) \(height * scale)" width="\(size)" height="\(size)">
          <rect width="100%" height="100%" fill="\(bgHex)"/>
          \(rects)
        </svg>
        """
    }

    // MARK: - Barcode Generation

    func generateBarcode(from content: String, size: CGSize = CGSize(width: 300, height: 100)) -> UIImage? {
        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = Data(content.utf8)
        filter.quietSpace = 10

        guard let ciImage = filter.outputImage else { return nil }
        let scaleX = size.width / ciImage.extent.size.width
        let scaleY = size.height / ciImage.extent.size.height
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
