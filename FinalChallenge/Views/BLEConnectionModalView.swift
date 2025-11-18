//
//  BLEConnectionModalView.swift
//  FinalChallenge
//
//  Created by Euginia Gabrielle on 16/11/25.
//

import SwiftUI

struct BLEConnectionModalView: View {
    @EnvironmentObject var bleVM: BLEViewModel
    var onCancel: () -> Void
    
    private var statusString: String {
        switch bleVM.state {
        case .idle:
            return "Disconnected"
        case .scanning:
            return "Scanning..."
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .failed(let error):
            if error == "Disconnected" { return "Disconnected" }
            return "Connection Failed"
        }
    }
    
    private var statusColor: Color {
        switch bleVM.state {
        case .connected:
            return .greenButton
        case .failed:
            return .red
        default:
            return .yellow.opacity(0.7)
        }
    }
    
    private var isBusy: Bool {
        bleVM.state == .scanning || bleVM.state == .connecting
    }
    
    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Button {
                    onCancel()
                } label: {
                    Image("closeButton")
                }
                
                Text("Device Connection")
                    .font(.custom("audiowide", size: 24))
                    .foregroundColor(.white)
            }
            
            // Status view
            VStack {
                Text("STATUS")
                    .font(.custom("audiowide", size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(statusString)
                    .font(.custom("audiowide", size: 20))
                    .foregroundColor(statusColor)
                
                // If connected, show device name
                if bleVM.state == .connected {
                    Text(bleVM.connectedName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
            
            // Action button
            if bleVM.state == .connected {
                // Disconnect button
                Button {
                    bleVM.disconnect()
                } label: {
                    Text("Disconnect")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                }
            } else {
                // Scan or Connect button
                Button {
                    bleVM.startScan(isReconnect: true)
                } label: {
                    Text(isBusy ? "Scanning..." : "Scan for Device")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isBusy)
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(Image("frame_top").opacity(0.5))
                .shadow(radius: 10)
        )
        .padding(40)
    }
}

#Preview {
    BLEConnectionModalView(onCancel: {})
        .environmentObject(BLEViewModel())
        .background(Color.gray)
}
