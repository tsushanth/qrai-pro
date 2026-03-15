// QRStyleView.swift
// QRAI Pro

import SwiftUI

struct QRStyleView: View {
    @Binding var style: QRStyle
    let isPremium: Bool
    @State private var showColorPicker = false
    @State private var showLogoPicker = false
    @State private var colorTarget: ColorTarget = .foreground

    enum ColorTarget { case foreground, background, gradient }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Style")
                .font(.headline)

            // Colors
            HStack(spacing: 16) {
                colorButton(label: "Foreground", color: style.foregroundSwiftUIColor) {
                    colorTarget = .foreground
                    showColorPicker = true
                }
                colorButton(label: "Background", color: style.backgroundSwiftUIColor) {
                    colorTarget = .background
                    showColorPicker = true
                }
            }

            // Gradient toggle (premium)
            Toggle(isOn: Binding(
                get: { style.gradientEnabled },
                set: { val in
                    if !isPremium && val {
                        // show paywall via parent
                    } else {
                        style.gradientEnabled = val
                    }
                }
            )) {
                HStack {
                    Text("Gradient")
                        .font(.subheadline)
                    if !isPremium {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .disabled(!isPremium)

            // Error Correction
            HStack {
                Text("Error Correction")
                    .font(.subheadline)
                Spacer()
                Picker("", selection: $style.errorCorrection) {
                    ForEach(QRErrorCorrection.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.menu)
            }

            // Dot style (premium)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Dot Style")
                        .font(.subheadline)
                    if !isPremium {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack(spacing: 8) {
                    ForEach(QRDotStyle.allCases, id: \.self) { dotStyle in
                        Button(action: {
                            if isPremium || !dotStyle.isPremium {
                                style.dotStyle = dotStyle
                            }
                        }) {
                            Text(dotStyle.displayName)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(style.dotStyle == dotStyle ? AppConstants.Colors.qrBlue : AppConstants.Colors.secondaryBackground)
                                .foregroundStyle(style.dotStyle == dotStyle ? .white : .primary)
                                .clipShape(Capsule())
                                .opacity(dotStyle.isPremium && !isPremium ? 0.5 : 1.0)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerView(
                selectedColor: Binding(
                    get: {
                        switch colorTarget {
                        case .foreground: return style.foregroundSwiftUIColor
                        case .background: return style.backgroundSwiftUIColor
                        case .gradient: return style.gradientEndSwiftUIColor
                        }
                    },
                    set: { newColor in
                        switch colorTarget {
                        case .foreground: style.foregroundColor = CodableColor(color: newColor)
                        case .background: style.backgroundColor = CodableColor(color: newColor)
                        case .gradient: style.gradientEndColor = CodableColor(color: newColor)
                        }
                    }
                ),
                title: colorTarget == .foreground ? "Foreground Color" : "Background Color"
            )
        }
    }

    private func colorButton(label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(width: 24, height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppConstants.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity)
    }
}
