//
//  BLERow.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI

struct BLERow: View {
    let name: String
    let id: String
    let rssi: Int?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name.isEmpty ? "Unknown" : name)
                    .font(.headline)
                Text(String(id.prefix(8)) + "…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let rssi {
                Text("RSSI: \(rssi)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BLERow(name: "LightBlue (Robo)",
           id: "E5F3A1B2-CDEF-4455-8899-1122AABB",
           rssi: -62)
}
