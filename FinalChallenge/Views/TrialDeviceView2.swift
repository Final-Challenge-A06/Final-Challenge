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
        ZStack(alignment: .bottom) {
            Image("bgTrialDevice")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer(minLength: 40)
                
                VStack(spacing: 18) {
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
                .padding(.top, 16)
                .offset(y: -140)
                
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
                .padding(.leading, 100)
                .padding(.bottom, 175)
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
