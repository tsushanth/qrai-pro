// WiFiQRView.swift
// QRAI Pro

import SwiftUI

struct WiFiQRView: View {
    @Binding var ssid: String
    @Binding var password: String
    @Binding var security: String
    @Binding var hidden: Bool

    let securityTypes = ["WPA", "WEP", "nopass"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WiFi Network")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("Network Name (SSID)", text: $ssid)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled()

            Picker("Security", selection: $security) {
                ForEach(securityTypes, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Hidden Network", isOn: $hidden)
                .font(.subheadline)
        }
    }
}
