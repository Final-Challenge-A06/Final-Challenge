//
//  BLETestView.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI
import CoreBluetooth

struct BLETestView: View {
    @StateObject private var vm = BLEViewModel()   // <-- benar: StateObject kalau dibuat di sini

    var body: some View {
        VStack(spacing: 12) {
            // Header & kontrol scan
            HStack {
                Button("Scan") { vm.startScan() }
                Button("Stop") { vm.stopScan() }
                Spacer()
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // List perangkat, diurutkan RSSI terkuat
            List {
                ForEach(sortedPeripherals, id: \.identifier) { p in
                    BLERow(
                        name: p.name ?? "",
                        id: p.identifier.uuidString,
                        rssi: vm.rssiMap[p.identifier]?.intValue
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { vm.connect(p) }
                }
            }

            // Area setelah tersambung
            if vm.stateConnected {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Connected to \(vm.connectedName)").bold()

                    BLEInputField(text: $vm.outText) {
                        vm.write()
                    }

                    HStack {
                        Button("Read") { vm.read() }
                        Text("Incoming: \(vm.incomingText)")
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }

    // MARK: - Helpers
    private var sortedPeripherals: [CBPeripheral] {
        vm.devices.sorted { a, b in
            let ra = vm.rssiMap[a.identifier]?.intValue ?? -127
            let rb = vm.rssiMap[b.identifier]?.intValue ?? -127
            return ra > rb
        }
    }

    private var statusText: String {
        switch vm.state {
        case .idle: return "Idle"
        case .scanning: return "Scanning…"
        case .list: return "Found devices"
        case .connecting: return "Connecting…"
        case .connected: return "Connected"
        case .failed(let reason): return "Failed: \(reason)"
        }
    }
}

private extension BLEViewModel {
    var stateConnected: Bool {
        if case .connected = state { return true }
        return false
    }
}

#Preview {
    BLETestView()
}
