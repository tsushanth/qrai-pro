// LocationQRView.swift
// QRAI Pro

import SwiftUI
import MapKit

struct LocationQRView: View {
    @Binding var latitude: String
    @Binding var longitude: String
    @Binding var label: String

    var coordinateValid: Bool {
        Double(latitude) != nil && Double(longitude) != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                TextField("Latitude (e.g. 40.7128)", text: $latitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                TextField("Longitude (e.g. -74.0060)", text: $longitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }

            TextField("Label (optional)", text: $label)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if coordinateValid, let lat = Double(latitude), let lon = Double(longitude) {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )))
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(true)
            }
        }
    }
}
