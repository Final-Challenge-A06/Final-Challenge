//
//  TrialDeviceIntroView.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 04/11/25.
//

import SwiftUI

struct TrialDeviceIntroView: View {
    @ObservedObject var vm: BLEViewModel
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
    
    private let zigzagNormal: CGFloat = 40
    @State private var showStep2 = false
    @AppStorage("hasCompletedTrial") private var hasCompletedTrial: Bool = false
    
    var body: some View {
        ZStack {
            Image("bgTrialDevice")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack() {
                Text("To activate bot try insert your money")
                    .font(.custom("Audiowide", size: 30))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .multilineTextAlignment(.center)
                
                Image("piggyBankTrialDevice")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 270)
                    .padding(.top, 10)
                
                VStack(spacing: 18) {
                    ForEach(0..<4, id: \.self) { step in
                        let isLarge = (step == 0 || step == 3)
                        let isLeft = (step % 2 == 0)
                        let xOffset = isLarge ? 0 : (isLeft ? -zigzagNormal : zigzagNormal)
                        
                        Image("ss_before")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 225)
                            .offset(x: xOffset)
                    }
                }
                
                BottomItemSelectionView(viewModel: bottomItemsVM)
                    .padding(.horizontal, 30)
            }
            .padding(.horizontal, 20)
        }
        .onChange(of: hasCompletedTrial) { _, done in
            if done { showStep2 = true }
        }
        .onChange(of: vm.lastBalance) { _, newValue in
            if newValue > 0 {
                showStep2 = true
                hasCompletedTrial = true
            }
        }
        .onAppear {
            if hasCompletedTrial || vm.lastBalance > 0 {
                showStep2 = true
                if vm.lastBalance > 0 { hasCompletedTrial = true }
            }
        }
        .fullScreenCover(isPresented: $showStep2) {
            TrialDeviceStep2View()
        }
        .environmentObject(vm)
    }
}

#Preview {
    TrialDeviceIntroView(vm: BLEViewModel())
        .environmentObject(BLEViewModel())
}
