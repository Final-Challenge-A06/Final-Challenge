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
    
    // Animation states
    @State private var robotScale: CGFloat = 0.3
    @State private var robotOpacity: Double = 0
    @State private var robotRotation: Double = -15
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    @State private var buttonScale: CGFloat = 0.8
    @State private var buttonOpacity: Double = 0
    @State private var isButtonPulsing = false
    @State private var robotFloating = false
    
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
                    .scaleEffect(robotScale)
                    .opacity(robotOpacity)
                    .rotationEffect(.degrees(robotRotation))
                    .offset(y: robotFloating ? -10 : 10)
                    .animation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                        value: robotFloating
                    )
                
                VStack(spacing: 8) {
                    if case .scanning = bleVM.state {
                        Text("SCANNING...")
                            .font(.custom("Audiowide", size: 26))
                            .kerning(1)
                            .textCase(.uppercase)
                            .foregroundColor(.white)
                            .opacity(textOpacity)
                            .offset(y: textOffset)
                        
                        HStack(spacing: 8) {
                            ProgressView().tint(.white)
                            Text("Scanning nearby devices…")
                                .font(.custom("Audiowide", size: 14))
                                .foregroundColor(.white)
                        }
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                    } else {
                        Text("NO \"BOT\" DETECTED")
                            .font(.custom("Audiowide", size: 26))
                            .textCase(.uppercase)
                            .foregroundColor(.white)
                            .opacity(textOpacity)
                            .offset(y: textOffset)
                        
                        Text("have your bot near you at all time")
                            .font(.custom("Audiowide", size: 24))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .opacity(textOpacity)
                            .offset(y: textOffset)
                    }
                }
                .padding(.bottom, 50)
                
                Button {
                    bleVM.startScan()
                } label: {
                    Text("+Link your Bot")
                        .font(.custom("Audiowide", size: 26))
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 12)
                .padding(.horizontal, 100)
                .background(Color.yellow.opacity(0.7))
                .cornerRadius(20)
                .scaleEffect(isButtonPulsing ? 1.05 : buttonScale)
                .opacity(buttonOpacity)
                .animation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                    value: isButtonPulsing
                )
                
                Spacer()
            }
            .blur(radius: showFindDevice ? 6 : 0)
            .allowsHitTesting(!showFindDevice)
            .onAppear {
                startEntranceAnimations()
            }
            
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
    
    private func startEntranceAnimations() {
        // Robot entrance animation - bouncy spring effect
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            robotScale = 1.0
            robotOpacity = 1.0
            robotRotation = 0
        }
        
        // Start floating animation after entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            robotFloating = true
        }
        
        // Text slide up animation with delay
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            textOpacity = 1.0
            textOffset = 0
        }
        
        // Button entrance animation
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.7)) {
            buttonScale = 1.0
            buttonOpacity = 1.0
        }
        
        // Start button pulsing after it appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isButtonPulsing = true
        }
    }
}

#Preview {
    BLETestView()
        .environmentObject(BLEViewModel())
        .environmentObject(AppFlowViewModel())
}
