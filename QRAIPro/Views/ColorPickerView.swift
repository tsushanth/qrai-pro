// ColorPickerView.swift
// QRAI Pro

import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    let title: String
    @Environment(\.dismiss) private var dismiss

    let presets: [Color] = [
        .black, .white, Color(red: 0.18, green: 0.45, blue: 0.95),
        Color(red: 0.55, green: 0.25, blue: 0.92),
        Color(red: 0.18, green: 0.78, blue: 0.48),
        Color(red: 1.0, green: 0.55, blue: 0.10),
        .red, .pink, .orange, .yellow, .green, .teal, .cyan, .blue, .indigo, .purple, .brown, .gray
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Color wheel
                ColorPicker("Select Color", selection: $selectedColor, supportsOpacity: false)
                    .padding(.horizontal, 24)
                    .labelsHidden()

                // Preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedColor)
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)

                // Presets
                VStack(alignment: .leading, spacing: 12) {
                    Text("Presets")
                        .font(.headline)
                        .padding(.horizontal, 24)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(presets, id: \.self) { color in
                            Button(action: { selectedColor = color }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                selectedColor == color ? AppConstants.Colors.qrBlue : Color.gray.opacity(0.3),
                                                lineWidth: selectedColor == color ? 3 : 1
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
