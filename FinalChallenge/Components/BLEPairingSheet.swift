//
//  BLEPairingSheet.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI
import CoreBluetooth

struct BLEPairingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = BLEViewModel()
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Find Device")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if case .scanning = vm.state {
                            ProgressView()
                        } else {
                            Button("Scan") { vm.startScan() }
                        }
                    }
                }
        }
        .onAppear { vm.startScan() }
        .onDisappear { vm.stopScan() }
    }
    
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .scanning:
            VStack(spacing: 12) {
                Spacer()
                ProgressView()
                Text("Scanning for \(BLEConst.service.uuidString)").foregroundColor(.secondary)
                Spacer()
            }
            
        case .list, .connecting, .failed:
            List(vm.devices, id: \.identifier) { p in
                BLERow(
                    name: p.name ?? "Unknown",
                    id: p.identifier.uuidString,
                    rssi: vm.rssiMap[p.identifier]?.intValue
                )
                .contentShape(Rectangle())
                .onTapGesture { vm.connect(p) }
            }
            .overlay {
                if case .connecting = vm.state { ProgressView("Connecting…") }
            }
            
        case .connected:
            VStack(spacing: 16) {
                Text("Connected to **\(vm.connectedName)**").font(.title3)
                HStack {
                    TextField("Type to send…", text: $vm.outText)
                        .textFieldStyle(.roundedBorder)
                    Button("Send") { vm.write() }
                        .buttonStyle(.borderedProminent)
                }
                Button("Read Value") { vm.read() }
                    .buttonStyle(.bordered)
                
                if !vm.incomingText.isEmpty {
                    Text("Last Value: \(vm.incomingText)")
                        .font(.callout).foregroundColor(.secondary)
                }
                
                Button("Disconnect", role: .destructive) { vm.disconnect() }
                    .padding(.top, 8)
                Spacer()
            }
            .padding()
        }
    }
}
#Preview {
    BLEPairingSheet()
}
