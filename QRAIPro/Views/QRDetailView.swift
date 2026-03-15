// QRDetailView.swift
// QRAI Pro

import SwiftUI
import SwiftData

struct QRDetailView: View {
    var scanResult: ScanResult?
    var qrCode: QRCodeItem?
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // QR Image or Icon
                if let code = qrCode, let data = code.imageData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(height: 220)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                } else {
                    let displayType = scanResult?.detectedType ?? qrCode?.type ?? .text
                    ZStack {
                        Circle()
                            .fill(displayType.color.opacity(0.15))
                            .frame(width: 120, height: 120)
                        Image(systemName: displayType.icon)
                            .font(.system(size: 52))
                            .foregroundStyle(displayType.color)
                    }
                }

                // Details
                VStack(spacing: 12) {
                    if let scan = scanResult {
                        detailRow("Type", scan.codeType)
                        detailRow("Scanned", scan.scannedAt.formatted(date: .abbreviated, time: .shortened))
                        detailRow("Content", scan.rawValue)
                        if !scan.note.isEmpty {
                            detailRow("Note", scan.note)
                        }
                    }

                    if let code = qrCode {
                        detailRow("Type", code.type.displayName)
                        detailRow("Created", code.createdAt.formatted(date: .abbreviated, time: .shortened))
                        detailRow("Content", code.content)
                        detailRow("Title", code.title)
                    }
                }
                .padding(.horizontal, 16)

                // Actions
                actionButtons
            }
            .padding(.vertical, 24)
        }
        .navigationTitle(scanResult?.title ?? qrCode?.title ?? "Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .pink : .primary)
                }
            }
        }
        .alert("Delete?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteItem()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var isFavorite: Bool {
        scanResult?.isFavorite ?? qrCode?.isFavorite ?? false
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.body)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppConstants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if let scan = scanResult, scan.isURL {
                Button(action: {
                    if let url = URL(string: scan.rawValue) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Open in Browser", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 16)
            }

            Button(action: copyContent) {
                Label("Copy Content", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
            .padding(.horizontal, 16)

            if let code = qrCode, let data = code.imageData, let img = UIImage(data: data) {
                Button(action: { shareImage(img) }) {
                    Label("Share QR Code", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.horizontal, 16)
            }

            Button(role: .destructive, action: { showDeleteAlert = true }) {
                Label("Delete", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .font(.headline)
                    .foregroundStyle(.red)
                    .padding(.vertical, 14)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
        }
    }

    private func copyContent() {
        let content = scanResult?.rawValue ?? qrCode?.content ?? ""
        UIPasteboard.general.string = content
        HapticsManager.shared.impact(.light)
    }

    private func shareImage(_ image: UIImage) {
        ExportService.shared.share(image: image)
    }

    private func toggleFavorite() {
        if let scan = scanResult {
            HistoryService.shared.toggleFavoriteScan(scan, in: modelContext)
        } else if let code = qrCode {
            HistoryService.shared.toggleFavoriteQR(code, in: modelContext)
        }
        HapticsManager.shared.impact(.light)
    }

    private func deleteItem() {
        if let scan = scanResult {
            HistoryService.shared.deleteScanResult(scan, from: modelContext)
        } else if let code = qrCode {
            HistoryService.shared.deleteQRCode(code, from: modelContext)
        }
    }
}
