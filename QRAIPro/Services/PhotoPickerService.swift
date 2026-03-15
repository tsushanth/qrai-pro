// PhotoPickerService.swift
// QRAI Pro

import Foundation
import PhotosUI
import SwiftUI

@MainActor
@Observable
final class PhotoPickerService {
    var selectedImage: UIImage?
    var isLoading = false
    var error: String?

    func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        isLoading = true
        error = nil
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func reset() {
        selectedImage = nil
        error = nil
    }
}
