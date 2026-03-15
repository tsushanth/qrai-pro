// QRTypeView.swift
// QRAI Pro

import SwiftUI

struct QRTypeView: View {
    @Binding var selectedType: QRType
    let isPremium: Bool
    let onSelect: (QRType) -> Void

    let columns = [GridItem(.adaptive(minimum: 80))]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QR Type")
                .font(.headline)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(QRType.allCases) { type in
                        QRTypeChip(
                            type: type,
                            isSelected: selectedType == type,
                            isPremium: isPremium
                        )
                        .onTapGesture { onSelect(type) }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct QRTypeChip: View {
    let type: QRType
    let isSelected: Bool
    let isPremium: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: type.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? .white : type.color)
                    .frame(width: 52, height: 52)
                    .background(isSelected ? type.color : type.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                if type.isPremium && !isPremium {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .offset(x: 4, y: -4)
                }
            }

            Text(type.displayName)
                .font(.caption2)
                .foregroundStyle(isSelected ? type.color : .secondary)
                .lineLimit(1)
        }
        .frame(width: 64)
    }
}
