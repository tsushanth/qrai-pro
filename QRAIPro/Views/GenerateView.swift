// GenerateView.swift
// QRAI Pro

import SwiftUI
import SwiftData

struct GenerateView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PremiumManager.self) private var premiumManager
    @State private var viewModel = GenerateViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Type Selector
                    QRTypeView(
                        selectedType: $viewModel.selectedType,
                        isPremium: premiumManager.isPremium,
                        onSelect: { type in
                            viewModel.selectType(type, isPremium: premiumManager.isPremium)
                        }
                    )

                    // Input Form
                    inputForm

                    // Title input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name (optional)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("My QR Code", text: $viewModel.title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal, 16)

                    // Style options
                    QRStyleView(style: $viewModel.style, isPremium: premiumManager.isPremium)
                        .padding(.horizontal, 16)

                    // Generate Button
                    Button(action: {
                        viewModel.generateQRCode(isPremium: premiumManager.isPremium)
                    }) {
                        HStack {
                            if viewModel.isGenerating {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(viewModel.isGenerating ? "Generating..." : "Generate QR Code")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.isContentValid ? AppConstants.Colors.gradient : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(!viewModel.isContentValid || viewModel.isGenerating)
                    .padding(.horizontal, 16)

                    // Preview
                    if let image = viewModel.generatedImage {
                        QRPreviewView(
                            image: image,
                            svgString: viewModel.generatedSVG,
                            isPremium: premiumManager.isPremium,
                            onSave: { viewModel.saveQRCode(to: modelContext) },
                            onShowPaywall: { viewModel.showPaywall = true }
                        )
                        .padding(.horizontal, 16)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Generate")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !premiumManager.isPremium {
                        Button("Pro") { viewModel.showPaywall = true }
                            .tint(AppConstants.Colors.qrPurple)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.generatedImage != nil {
                        Button("Reset") { viewModel.resetForm() }
                            .tint(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
        .alert("QR Code Saved!", isPresented: $viewModel.showSavedAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var inputForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch viewModel.selectedType {
            case .wifi:
                WiFiQRView(
                    ssid: $viewModel.wifiSSID,
                    password: $viewModel.wifiPassword,
                    security: $viewModel.wifiSecurity,
                    hidden: $viewModel.wifiHidden
                )
            case .contact:
                ContactQRView(
                    firstName: $viewModel.contactFirstName,
                    lastName: $viewModel.contactLastName,
                    phone: $viewModel.contactPhone,
                    email: $viewModel.contactEmail,
                    org: $viewModel.contactOrg,
                    url: $viewModel.contactURL
                )
            case .location:
                LocationQRView(
                    latitude: $viewModel.latitude,
                    longitude: $viewModel.longitude,
                    label: $viewModel.locationLabel
                )
            case .instagram, .twitter, .facebook, .linkedin, .tiktok, .whatsapp:
                SocialQRView(
                    type: viewModel.selectedType,
                    handle: $viewModel.content
                )
            default:
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.selectedType.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if viewModel.selectedType == .text {
                        TextEditor(text: $viewModel.content)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(AppConstants.Colors.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        TextField(viewModel.selectedType.placeholder, text: $viewModel.content)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(viewModel.selectedType == .phone || viewModel.selectedType == .sms ? .phonePad : .default)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
