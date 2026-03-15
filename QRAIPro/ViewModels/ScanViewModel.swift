// ScanViewModel.swift
// QRAI Pro

import Foundation
import SwiftUI
import AVFoundation
import SwiftData
import PhotosUI

@MainActor
@Observable
final class ScanViewModel: NSObject {
    var scannedCode: String = ""
    var scannedType: String = "QR"
    var isScanning = false
    var showResult = false
    var cameraPermissionDenied = false
    var isTorchOn = false
    var hasTorch: Bool = AVCaptureDevice.default(for: .video)?.hasTorch ?? false
    var scanHistory: [ScanResult] = []
    var selectedPhotoItem: PhotosPickerItem?
    var isProcessingPhoto = false
    var photoScanResults: [String] = []
    var showPhotoResults = false
    var errorMessage: String?

    private let scannerService = QRScannerService()

    override init() {
        super.init()
        scannerService.delegate = self
    }

    // MARK: - Camera Permission

    func checkCameraPermission() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if !granted { cameraPermissionDenied = true }
        case .denied, .restricted:
            cameraPermissionDenied = true
        @unknown default:
            break
        }
    }

    // MARK: - Scanner Control

    func startScanning(in view: UIView) {
        _ = scannerService.setupSession(in: view)
        scannerService.startScanning()
        isScanning = true
        AnalyticsService.shared.track(.scanStarted)
    }

    func stopScanning() {
        scannerService.stopScanning()
        isScanning = false
    }

    func toggleTorch() {
        isTorchOn.toggle()
        scannerService.isTorchOn = isTorchOn
        HapticsManager.shared.impact(.light)
    }

    func focusAt(_ point: CGPoint, in view: UIView) {
        scannerService.focusAt(point, in: view)
    }

    // MARK: - Photo Scan

    func scanPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        isProcessingPhoto = true
        photoScanResults = []

        let pickerService = PhotoPickerService()
        await pickerService.loadImage(from: item)

        if let image = pickerService.selectedImage {
            photoScanResults = await scannerService.scanImage(image)
            showPhotoResults = !photoScanResults.isEmpty
            if photoScanResults.isEmpty {
                errorMessage = "No QR code found in the image."
            }
        }
        isProcessingPhoto = false
    }

    // MARK: - Process Scan Result

    func processScan(_ value: String, type: String, modelContext: ModelContext) {
        let result = ScanResult(rawValue: value, codeType: type)
        HistoryService.shared.addScanResult(result, to: modelContext)
        HapticsManager.shared.success()
        AnalyticsService.shared.track(.scanCompleted(type: type))
        ReviewManager.shared.requestReviewIfAppropriate()
    }

    func dismissResult() {
        showResult = false
        scannedCode = ""
    }
}

// MARK: - QRScannerDelegate

extension ScanViewModel: QRScannerDelegate {
    nonisolated func scannerDidDetectCode(_ code: String, type: String) {
        Task { @MainActor in
            guard !showResult else { return }
            scannedCode = code
            scannedType = type
            showResult = true
            stopScanning()
        }
    }

    nonisolated func scannerDidFail(with error: Error) {
        Task { @MainActor in
            errorMessage = error.localizedDescription
        }
    }
}
