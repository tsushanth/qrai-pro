// QRStyle.swift
// QRAI Pro

import Foundation
import SwiftUI

enum QRDotStyle: String, CaseIterable, Codable {
    case square = "Square"
    case rounded = "Rounded"
    case circle = "Circle"
    case diamond = "Diamond"

    var displayName: String { rawValue }
    var isPremium: Bool {
        switch self {
        case .square: return false
        default: return true
        }
    }
}

enum QREyeStyle: String, CaseIterable, Codable {
    case square = "Square"
    case rounded = "Rounded"
    case circle = "Circle"
    case leaf = "Leaf"

    var displayName: String { rawValue }
    var isPremium: Bool {
        switch self {
        case .square: return false
        default: return true
        }
    }
}

enum QRErrorCorrection: String, CaseIterable, Codable {
    case low = "L"
    case medium = "M"
    case quartile = "Q"
    case high = "H"

    var displayName: String {
        switch self {
        case .low: return "Low (7%)"
        case .medium: return "Medium (15%)"
        case .quartile: return "Quartile (25%)"
        case .high: return "High (30%)"
        }
    }
}

struct QRStyle: Codable, Equatable {
    var foregroundColor: CodableColor
    var backgroundColor: CodableColor
    var dotStyle: QRDotStyle
    var eyeStyle: QREyeStyle
    var errorCorrection: QRErrorCorrection
    var logoData: Data?
    var logoScale: CGFloat
    var gradientEnabled: Bool
    var gradientEndColor: CodableColor

    static let defaultStyle = QRStyle(
        foregroundColor: CodableColor(color: .black),
        backgroundColor: CodableColor(color: .white),
        dotStyle: .square,
        eyeStyle: .square,
        errorCorrection: .medium,
        logoData: nil,
        logoScale: 0.2,
        gradientEnabled: false,
        gradientEndColor: CodableColor(color: .blue)
    )

    var foregroundSwiftUIColor: Color { foregroundColor.color }
    var backgroundSwiftUIColor: Color { backgroundColor.color }
    var gradientEndSwiftUIColor: Color { gradientEndColor.color }
}

struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}
