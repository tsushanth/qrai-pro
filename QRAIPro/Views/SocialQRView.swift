// SocialQRView.swift
// QRAI Pro

import SwiftUI

struct SocialQRView: View {
    let type: QRType
    @Binding var handle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .foregroundStyle(type.color)
                Text(type.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField(type.placeholder, text: $handle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !handle.isEmpty {
                Text("URL: \(type.encode(content: handle))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }
}
