//
//  TrialDeviceView2.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 04/11/25.
//

import SwiftUI

struct TrialDeviceStep2View: View {
    @EnvironmentObject var vm: BLEViewModel
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
    
    @State private var showReward = false
    @AppStorage("hasCompletedTrial") private var hasCompletedTrial: Bool = false
    
    var body: some View {
        ZStack() {
            Image("bgTrialDevice")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Image("ss_before")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 246)
                    .rotationEffect(Angle(degrees: -10))
                    .offset(y: 270)
                
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
                    showReward = true
                    hasCompletedTrial = true
                }
                
                SavingCardView(
                    title: "My Saving",
                    totalSaving: formattedBalance(vm.lastBalance)
                )
                .offset(x:-320, y: 230)
                
                BottomItemSelectionView(viewModel: bottomItemsVM)
                    .padding(.horizontal, 30)
                    .offset(y: 300)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20)
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
