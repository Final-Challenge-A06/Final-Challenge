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
            return .yellow
        }
    }
    
    private var isBusy: Bool {
        bleVM.state == .scanning || bleVM.state == .connecting
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Spacer()
                
                Text("Device Connection")
                    .font(.custom("audiowide", size: 32))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    SoundManager.shared.play(.buttonCloseClick)
                    onCancel()
                } label: {
                    Image("closeButton")
                }
            }
            
            // Status view
            VStack {
                Text("Status")
                    .font(.custom("audiowide", size: 24))
                    .foregroundColor(.white)
                
                Text(statusString)
                    .font(.custom("audiowide", size: 24))
                    .foregroundColor(statusColor)
                
                // If connected, show device name
                if bleVM.state == .connected {
                    Text(bleVM.connectedName)
                        .font(.custom("audiowide", size: 20))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.bottom, 30)
            
            // Action button
            if bleVM.state == .connected {
                // Disconnect button
                Button {
                    SoundManager.shared.play(.buttonCloseClick)
                    bleVM.disconnect()
                } label: {
                    Text("Disconnect")
                        .font(.custom("audiowide", size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 80)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                }
            } else {
                // Scan or Connect button
                Button {
                    SoundManager.shared.play(.buttonClick)
                    bleVM.startScan(isReconnect: true)
                } label: {
                    Text(isBusy ? "Scanning..." : "Scan for Device")
                        .font(.custom("audiowide", size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 100)
                        .padding(.vertical, 10)
                        .background(Color.yellowButton, in: RoundedRectangle(cornerRadius: 50))
                }
                .disabled(isBusy)
            }
        }
        .padding(.horizontal, 190)
        .padding(.bottom, 40)
        .background(
            Image("modal_gift")
        )
    }
}

#Preview {
    BLEConnectionModalView(onCancel: {})
        .environmentObject(BLEViewModel())
}
