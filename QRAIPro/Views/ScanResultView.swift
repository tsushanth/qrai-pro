// ScanResultView.swift
// QRAI Pro

import SwiftUI

struct ScanResultView: View {
    let scannedValue: String
    let codeType: String
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showCopiedAlert = false

    private var detectedType: QRType {
        ScanResult(rawValue: scannedValue, codeType: codeType).detectedType
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Type icon
                    ZStack {
                        Circle()
                            .fill(detectedType.color.opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: detectedType.icon)
                            .font(.system(size: 44))
                            .foregroundStyle(detectedType.color)
                    }
                    .padding(.top, 32)

                    // Code type badge
                    Text(codeType)
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(detectedType.color.opacity(0.15))
                        .foregroundStyle(detectedType.color)
                        .clipShape(Capsule())

                    // Value
                    VStack(spacing: 8) {
                        Text(detectedType.displayName)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text(scannedValue)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .textSelection(.enabled)
                            .padding(.horizontal, 24)
                    }

                    Divider()

                    // Actions
                    actionButtons

                    Spacer()
                }
            }
            .navigationTitle("Scan Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
        .overlay {
            if showCopiedAlert {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Copied!")
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 120)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Open URL
            if scannedValue.hasPrefix("http") {
                Button(action: {
                    if let url = URL(string: scannedValue) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Open in Browser", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }

            // Open specific types
            switch detectedType {
            case .phone:
                Button(action: { openScheme(scannedValue.hasPrefix("tel:") ? scannedValue : "tel:\(scannedValue)") }) {
                    Label("Call", systemImage: "phone")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            case .email:
                Button(action: { openScheme(scannedValue) }) {
                    Label("Send Email", systemImage: "envelope")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            case .sms:
                Button(action: { openScheme(scannedValue) }) {
                    Label("Send Message", systemImage: "message")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            default:
                EmptyView()
            }

            // Copy
            Button(action: copyToClipboard) {
                Label("Copy", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())

            // Share
            Button(action: share) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.horizontal, 24)
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = scannedValue
        HapticsManager.shared.impact(.light)
        withAnimation { showCopiedAlert = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopiedAlert = false }
        }
    }

    private func share() {
        let activityVC = UIActivityViewController(activityItems: [scannedValue], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?
            .present(activityVC, animated: true)
        AnalyticsService.shared.track(.shareQR(type: codeType))
    }

    private func openScheme(_ scheme: String) {
        if let url = URL(string: scheme) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .background(AppConstants.Colors.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppConstants.Colors.qrBlue)
            .padding(.vertical, 14)
            .background(AppConstants.Colors.qrBlue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
