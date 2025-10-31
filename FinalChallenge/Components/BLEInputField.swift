//
//  BLEInputField.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 31/10/25.
//

import SwiftUI

struct BLEInputField: View {
    @Binding var text: String
    var onSend: () -> Void

    var body: some View {
        HStack {
            TextField("type text…", text: $text)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            Button("Write") { onSend() }
                .buttonStyle(.borderedProminent)
        }
    }
}

private struct BLEInputField_PreviewHost: View {
    @State private var t: String = "hello"
    var body: some View {
        BLEInputField(text: $t) {
        }
        .padding()
    }
}

#Preview {
    BLEInputField_PreviewHost()
}

