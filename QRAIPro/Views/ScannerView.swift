// ScannerView.swift
// QRAI Pro

import SwiftUI
import AVFoundation
import PhotosUI
import SwiftData

struct ScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ScanViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showPermissionAlert = false
    @State private var showPhotoPicker = false

    var body: some View {
        navigationContent
            .task {
                await viewModel.checkCameraPermission()
                if viewModel.cameraPermissionDenied {
                    showPermissionAlert = true
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task { await viewModel.scanPhoto(newItem) }
            }
            .sheet(isPresented: $viewModel.showResult) {
                ScanResultView(
                    scannedValue: viewModel.scannedCode,
                    codeType: viewModel.scannedType,
                    onDismiss: {
                        viewModel.processScan(viewModel.scannedCode, type: viewModel.scannedType, modelContext: modelContext)
                        viewModel.dismissResult()
                        viewModel.startScanning(in: UIView())
                    }
                )
            }
            .sheet(isPresented: $viewModel.showPhotoResults) {
                PhotoScanResultsView(results: viewModel.photoScanResults)
            }
            .alert("Camera Access Required", isPresented: $showPermissionAlert) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow camera access in Settings to scan QR codes.")
            }
    }

    private var navigationContent: some View {
        NavigationStack {
            ZStack {
                CameraPreviewRepresentable(viewModel: viewModel)
                    .ignoresSafeArea()
                scannerOverlay
                VStack {
                    Spacer()
                    bottomControls
                }
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                photoPickerToolbarItem
                torchToolbarItem
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
        }
    }

    @ToolbarContentBuilder
    private var photoPickerToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { showPhotoPicker = true }) {
                Image(systemName: "photo.on.rectangle")
                    .foregroundStyle(.white)
            }
        }
    }

    @ToolbarContentBuilder
    private var torchToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: { viewModel.toggleTorch() }) {
                Image(systemName: viewModel.isTorchOn ? "bolt.fill" : "bolt.slash")
                    .foregroundStyle(.white)
            }
            .disabled(!viewModel.hasTorch)
        }
    }

    private var scannerOverlay: some View {
        GeometryReader { geo in
            ZStack {
                // Dark overlay
                Color.black.opacity(0.5)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: 260, height: 260)
                                    .blendMode(.destinationOut)
                            )
                    )
                    .ignoresSafeArea()

                // Scanner frame
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppConstants.Colors.qrBlue, lineWidth: 3)
                    .frame(width: 260, height: 260)

                // Corner markers
                ScannerCorners()
                    .frame(width: 260, height: 260)

                // Scanning line animation
                ScanLineView()
                    .frame(width: 240, height: 260)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 16) {
            Text("Point camera at a QR code or barcode")
                .font(.subheadline)
                .foregroundStyle(.white)
                .shadow(radius: 2)

            if viewModel.isProcessingPhoto {
                ProgressView()
                    .tint(.white)
            }
        }
        .padding(.bottom, 60)
    }
}

// MARK: - Camera Preview

struct CameraPreviewRepresentable: UIViewRepresentable {
    let viewModel: ScanViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        Task { @MainActor in
            viewModel.startScanning(in: view)
        }
        // Tap to focus
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No-op: focus is handled via tap gesture
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject {
        let viewModel: ScanViewModel
        var hostView: UIView?

        init(viewModel: ScanViewModel) {
            self.viewModel = viewModel
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view else { return }
            let point = gesture.location(in: view)
            Task { @MainActor in
                viewModel.focusAt(point, in: view)
            }
        }
    }
}

// MARK: - Scanner UI Components

struct ScannerCorners: View {
    let cornerLength: CGFloat = 24
    let lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            // Top-left
            Path { p in
                p.move(to: CGPoint(x: 0, y: cornerLength))
                p.addLine(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: cornerLength, y: 0))
            }
            .stroke(AppConstants.Colors.qrBlue, lineWidth: lineWidth)

            // Top-right
            GeometryReader { geo in
                Path { p in
                    p.move(to: CGPoint(x: geo.size.width - cornerLength, y: 0))
                    p.addLine(to: CGPoint(x: geo.size.width, y: 0))
                    p.addLine(to: CGPoint(x: geo.size.width, y: cornerLength))
                }
                .stroke(AppConstants.Colors.qrBlue, lineWidth: lineWidth)
            }

            // Bottom-left
            GeometryReader { geo in
                Path { p in
                    p.move(to: CGPoint(x: 0, y: geo.size.height - cornerLength))
                    p.addLine(to: CGPoint(x: 0, y: geo.size.height))
                    p.addLine(to: CGPoint(x: cornerLength, y: geo.size.height))
                }
                .stroke(AppConstants.Colors.qrBlue, lineWidth: lineWidth)
            }

            // Bottom-right
            GeometryReader { geo in
                Path { p in
                    p.move(to: CGPoint(x: geo.size.width - cornerLength, y: geo.size.height))
                    p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height - cornerLength))
                }
                .stroke(AppConstants.Colors.qrBlue, lineWidth: lineWidth)
            }
        }
    }
}

struct ScanLineView: View {
    @State private var offset: CGFloat = -120

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, AppConstants.Colors.qrBlue.opacity(0.8), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
            .offset(y: offset)
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                    offset = 120
                }
            }
    }
}

// MARK: - Photo Scan Results

struct PhotoScanResultsView: View {
    let results: [String]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(results, id: \.self) { result in
                Text(result)
                    .font(.body)
            }
            .navigationTitle("Scan Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
