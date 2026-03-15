// QRPreviewView.swift
// QRAI Pro

import SwiftUI

struct QRPreviewView: View {
    let image: UIImage
    let svgString: String
    let isPremium: Bool
    let onSave: () -> Void
    let onShowPaywall: () -> Void

    @State private var showShareSheet = false
    @State private var exportURL: URL?
    @State private var selectedFormat: ExportFormat = .png

    var body: some View {
        VStack(spacing: 16) {
            Text("Preview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // QR Preview
            Image(uiImage: image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(height: 240)
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

            // Export format picker
            HStack {
                Text("Format")
                    .font(.subheadline)
                Spacer()
                Picker("Format", selection: $selectedFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        HStack {
                            Text(format.rawValue)
                            if format.isPremium && !isPremium {
                                Image(systemName: "lock.fill")
                            }
                        }
                        .tag(format)
                    }
                }
                .pickerStyle(.menu)
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: onSave) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                Button(action: exportAndShare) {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(16)
        .background(AppConstants.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func exportAndShare() {
        if selectedFormat.isPremium && !isPremium {
            onShowPaywall()
            return
        }

        let export = ExportService.shared
        var url: URL?

        switch selectedFormat {
        case .png: url = export.exportAsPNG(image)
        case .jpeg: url = export.exportAsJPEG(image)
        case .svg: url = export.exportAsSVG(svgString)
        case .pdf: url = export.exportAsPDF(image)
        }

        if let url {
            exportURL = url
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows.first?.rootViewController?
                .present(activityVC, animated: true)
            AnalyticsService.shared.track(.exportQR(format: selectedFormat.rawValue))
        }
    }
}
