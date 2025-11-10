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
    @StateObject private var vm = BLEViewModel()
    @State private var showFindDevice = false
    @State private var showTrial = false
    @State private var showGoal = false
    @AppStorage("hasCompletedTrial") private var hasCompletedTrial: Bool = false
    
    var body: some View {
        ZStack {
            Image("background_main")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("robot_frame")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 550)
                
                VStack(spacing: 8) {
                    if case .scanning = vm.state {
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
                    vm.startScan()
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
                    connectedName: (vm.connectedName.isEmpty || vm.connectedName == "-") ? nil : vm.connectedName,
                    onClose: { withAnimation(.spring()) { showFindDevice = false } },
                    onSetup: { vm.tapSetup() },
                    onLearnMore: { /* TODO: action learn more */ }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.22), value: showFindDevice)
        .onAppear {
            vm.onShowFindDevice = { show in
                withAnimation(.spring()) { showFindDevice = show }
            }
            if vm.hasPairedOnce {
                if hasCompletedTrial {
                    showGoal = true
                } else {
                    showTrial = true
                }
            }
        }
        .onDisappear { vm.onShowFindDevice = nil }
        .onChange(of: vm.state) { _, newValue in
            switch newValue {
            case .connecting:
                withAnimation(.spring()) { showFindDevice = true }
            case .connected:
                withAnimation(.spring()) { showFindDevice = false }
                if hasCompletedTrial {
                    showGoal = true
                } else {
                    showTrial = true
                }
            case .failed:
                withAnimation(.spring()) { showFindDevice = false }
            default:
                break
            }
        }
        .fullScreenCover(isPresented: $showTrial) {
            TrialDeviceIntroView(vm: vm)  
        }
        .fullScreenCover(isPresented: $showGoal) {
            GoalView().environmentObject(vm)
        }
    }
    
    private var titleForModal: String {
        switch vm.state {
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
}
