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
            Image("backgroundFindDevice")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer(minLength: 0)
                
                Image("robot1")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 450)
                
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
                        Text("NO \"BOT\" FOUND")
                            .font(.custom("Audiowide", size: 26))
                            .kerning(1)
                            .textCase(.uppercase)
                            .foregroundColor(.white)
                        
                        Text("Activate your Bot and keep it close by")
                            .font(.custom("Audiowide", size: 16))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    }
                }
                
                Button {
                    vm.startScan()
                } label: {
                    Image("buttonLinkYourBot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320)
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
                
                Spacer(minLength: 60)
            }
            .padding(.horizontal, 24)
            .blur(radius: showFindDevice ? 6 : 0)
            .allowsHitTesting(!showFindDevice)
            
            if showFindDevice {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                let modalWidth: CGFloat = 450
                let innerHorz: CGFloat = 22
                let robotHeight: CGFloat = 128
                let buttonWidth: CGFloat = 280
                let buttonSpacing: CGFloat = 12
                
                VStack {
                    Spacer()
                    
                    Image("modalFindingBot")
                        .resizable(
                            capInsets: EdgeInsets(top: 32, leading: 32, bottom: 32, trailing: 32),
                            resizingMode: .stretch
                        )
                        .scaledToFit()
                        .frame(width: modalWidth)
                        .shadow(radius: 10, y: 6)
                        .overlay(
                            Button {
                                withAnimation(.spring()) { showFindDevice = false }
                            } label: {
                                Image("closeButton")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            }
                                .buttonStyle(.plain)
                                .padding(.top, 20)
                                .padding(.trailing, 20),
                            alignment: .topTrailing
                        )
                        .overlay(
                            VStack(spacing: 14) {
                                Text(titleForModal)
                                    .font(.custom("Audiowide", size: 24))
                                    .foregroundColor(.white)
                                    .padding(.top, 60)
                                
                                Image("blueRobot")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: robotHeight)
                                    .padding(.top, 4)
                                
                                if !vm.connectedName.isEmpty && vm.connectedName != "-" {
                                    Text(vm.connectedName)
                                        .font(.custom("Audiowide-", size: 16))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                VStack(spacing: buttonSpacing) {
                                    Button {
                                        vm.tapSetup()
                                    } label: {
                                        Image("setupButton")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: buttonWidth)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button { } label: {
                                        Image("learnmoreButton")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: buttonWidth)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.top, 6)
                                
                                Spacer(minLength: 14)
                            }
                                .padding(.horizontal, innerHorz),
                            alignment: .center
                        )
                    
                    Spacer()
                }
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
