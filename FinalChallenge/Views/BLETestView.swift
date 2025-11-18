//
//  BLETestView.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI
import CoreBluetooth
import Combine

struct BLETestView: View {
    @EnvironmentObject var bleVM: BLEViewModel
    @EnvironmentObject var flowVM: AppFlowViewModel
    
    @State private var showFindDevice = false
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
    
    var body: some View {
        mainBLEContent
    }
    
    private var mainBLEContent: some View {
        ZStack {
            Image("background_bluetooth")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("robot_frame")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 550)
                
                VStack(spacing: 8) {
                    if case .scanning = bleVM.state {
                        Text("SCANNING...")
                            .font(.custom("Audiowide", size: 26))
                            .kerning(1)
                            .textCase(.uppercase)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            ProgressView().tint(.white)
                            Text("Scanning nearby devices…")
                                .font(.custom("Audiowide", size: 14))
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("NO \"BOT\" DETECTED")
                            .font(.custom("Audiowide", size: 26))
                            .textCase(.uppercase)
                            .foregroundColor(.white)
                        
                        Text("have your bot near you at all time")
                            .font(.custom("Audiowide", size: 24))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 50)
                
                Button {
                    SoundManager.shared.play(.buttonClick)
                    bleVM.startScan()
                } label: {
                    Text("+Link your Bot")
                        .font(.custom("Audiowide", size: 26))
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 12)
                .padding(.horizontal, 100)
                .background(Color.yellowButton)
                .cornerRadius(20)
                
                Spacer()
            }
            .blur(radius: showFindDevice ? 6 : 0)
            .allowsHitTesting(!showFindDevice)
            
            if showFindDevice {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                FindingBotModal(
                    connectedName: (bleVM.connectedName.isEmpty || bleVM.connectedName == "-") ? nil : bleVM.connectedName,
                    onClose: {
                        withAnimation(.spring()) {
                            showFindDevice = false
                        }
                    },
                    onSetup: {
                        bleVM.tapSetup()
                        withAnimation(.spring()) {
                            showFindDevice = false
                            flowVM.markPairedOnce()
                            flowVM.goToStartOnboarding()
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            bleVM.onShowFindDevice = { show in
                withAnimation(.spring()) { showFindDevice = show }
            }
        }
        .onDisappear {
            bleVM.onShowFindDevice = nil
        }
        .onChange(of: bleVM.state) { _, newValue in
            switch newValue {
            case .connecting:
                withAnimation(.spring()) { showFindDevice = true }
            case .connected:
                withAnimation(.spring()) { showFindDevice = false }
            case .failed:
                withAnimation(.spring()) { showFindDevice = false }
            default:
                break
            }
        }
    }
    
    private var titleForModal: String {
        switch bleVM.state {
        case .connecting: return "Connecting..."
        case .connected:  return "Linked!"
        case .failed:     return "Connection Failed"
        case .scanning, .idle:
            return "Roboo Found!"
        }
    }
}

#Preview {
    BLETestView()
        .environmentObject(BLEViewModel())
        .environmentObject(AppFlowViewModel())
}
