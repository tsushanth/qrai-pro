// QRScannerService.swift
// QRAI Pro

import Foundation
import AVFoundation
import UIKit
import Vision

protocol QRScannerDelegate: AnyObject {
    func scannerDidDetectCode(_ code: String, type: String)
    func scannerDidFail(with error: Error)
}

final class QRScannerService: NSObject {
    weak var delegate: QRScannerDelegate?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isScanning = false

    var hasTorch: Bool { AVCaptureDevice.default(for: .video)?.hasTorch ?? false }

    var isTorchOn: Bool = false {
        didSet { setTorch(isTorchOn) }
    }

    // MARK: - Setup

    func setupSession(in view: UIView) -> AVCaptureVideoPreviewLayer? {
        let session = AVCaptureSession()
        captureSession = session

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return nil
        }

        guard session.canAddInput(input) else { return nil }
        session.addInput(input)

        let metadataOutput = AVCaptureMetadataOutput()
        guard session.canAddOutput(metadataOutput) else { return nil }
        session.addOutput(metadataOutput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = supportedObjectTypes

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        previewLayer = preview

        return preview
    }

    func startScanning() {
        guard !isScanning else { return }
        isScanning = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func stopScanning() {
        guard isScanning else { return }
        isScanning = false
        captureSession?.stopRunning()
        isTorchOn = false
    }

    func updatePreviewFrame(_ frame: CGRect) {
        previewLayer?.frame = frame
    }

    // MARK: - Torch

    private func setTorch(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    // MARK: - Focus

    func focusAt(_ point: CGPoint, in view: UIView) {
        guard let device = AVCaptureDevice.default(for: .video),
              let layer = previewLayer else { return }
        let devicePoint = layer.captureDevicePointConverted(fromLayerPoint: point)
        try? device.lockForConfiguration()
        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = devicePoint
            device.focusMode = .autoFocus
        }
        if device.isExposurePointOfInterestSupported {
            device.exposurePointOfInterest = devicePoint
            device.exposureMode = .autoExpose
        }
        device.unlockForConfiguration()
    }

    // MARK: - Scan from Image

    func scanImage(_ image: UIImage) async -> [String] {
        guard let cgImage = image.cgImage else { return [] }
        var results: [String] = []

        let request = VNDetectBarcodesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            if let observations = request.results {
                results = observations.compactMap { $0.payloadStringValue }
            }
        } catch {
            print("[Scanner] Image scan error: \(error)")
        }

        return results
    }

    // MARK: - Supported Types

    private var supportedObjectTypes: [AVMetadataObject.ObjectType] {
        [
            .qr,
            .ean8,
            .ean13,
            .code128,
            .code39,
            .code93,
            .pdf417,
            .aztec,
            .dataMatrix,
            .interleaved2of5,
            .itf14,
            .upce
        ]
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }

        let typeString: String
        switch readableObject.type {
        case .qr: typeString = "QR"
        case .ean13: typeString = "EAN-13"
        case .ean8: typeString = "EAN-8"
        case .code128: typeString = "Code 128"
        case .code39: typeString = "Code 39"
        case .pdf417: typeString = "PDF417"
        case .aztec: typeString = "Aztec"
        default: typeString = "Barcode"
        }

        delegate?.scannerDidDetectCode(stringValue, type: typeString)
    }
}
