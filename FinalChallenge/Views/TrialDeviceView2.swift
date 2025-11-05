//
//  TrialDeviceView2.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 04/11/25.
//

import SwiftUI

struct TrialDeviceStep2View: View {
    @EnvironmentObject var vm: BLEViewModel
    @State private var showReward = false
    @AppStorage("hasCompletedTrial") private var hasCompletedTrial: Bool = false
    private let zigzagNormal: CGFloat = 40
    
    var body: some View {
        ZStack() {
            Image("bgTrialDevice")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack{
                VStack() {
                    VStack() {
                        ForEach(0..<4, id: \.self) { step in
                            let isLarge = (step == 0 || step == 3)
                            let isLeft = (step % 2 == 0)
                            let xOffset = isLarge ? 0 : (isLeft ? -zigzagNormal : zigzagNormal)
                            
                            Image("ss_before")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isLarge ? 225 : 225)
                                .offset(x: xOffset)
                        }
                    }
                    
                    ZStack {
                        Image("claimButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                        
                        Text("Claim")
                            .font(.custom("Audiowide", size: 22))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                    }
                    .buttonStyle(.plain)
                    .onTapGesture { showReward = true }
                    .offset(y: -430)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
                
                ZStack {
                    Image("claimButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    
                    Text("Claim")
                        .font(.custom("Audiowide", size: 22))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                }
                .buttonStyle(.plain)
                .onTapGesture {
                    hasCompletedTrial = true
                    showReward = true
                }
                .offset(y: -430)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20)
            
            VStack {
                Spacer()
                HStack {
                    SavingCardView(
                        title: "My Saving",
                        totalSaving: formattedBalance(vm.lastBalance)
                    )
                    .fixedSize()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                BottomItemSelectionView(viewModel: bottomItemsVM)
                    .padding(.horizontal, 50)
                    .padding(.top, 50)
            }
            .frame(maxWidth: .infinity)
            
        }
        .fullScreenCover(isPresented: $showReward) {
            RewardClaimView(vm: vm)
                .environmentObject(vm)
        }
    }
    
    private func formattedBalance(_ value: Int64) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = "."
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

#Preview {
    let vm = BLEViewModel()
    vm.lastBalance = 0
    return TrialDeviceStep2View()
        .environmentObject(vm)
}
