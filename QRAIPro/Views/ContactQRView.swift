// ContactQRView.swift
// QRAI Pro

import SwiftUI

struct ContactQRView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var phone: String
    @Binding var email: String
    @Binding var org: String
    @Binding var url: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            TextField("Phone", text: $phone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            TextField("Organization (optional)", text: $org)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Website (optional)", text: $url)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }
}
