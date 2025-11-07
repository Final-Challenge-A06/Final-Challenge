import SwiftUI

struct RewardClaimView: View {
    @ObservedObject var vm: BLEViewModel
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @State private var showGoal = false
    
    var body: some View {
        ZStack {
            Image("bgTrialDevice")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    Image("rewardModal")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 600)
                    
                    VStack(spacing: 10) {
                        Text("NEW ACCESSORIES")
                            .font(.custom("Audiowide", size: 26))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                        
                        Text("3D GLASSES")
                            .font(.custom("Audiowide", size: 26))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                        
                        Image("glasses")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160)
                            .padding(.top, 4)
                        
                        Button {
                            showGoal = true
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.yellow)
                                .shadow(radius: 4)
                        }
                        
                        BottomItemSelectionView(viewModel: bottomItemsVM)
                            .offset(y: 450)
                            .padding(.horizontal, 30)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 120)
        }
        .overlay(
            HStack {
                SavingCardView(
                    title: "My Saving",
                    totalSaving: formattedBalance(Double(vm.lastBalance))
                )
                Spacer()
            }
            .padding(.leading, 80)
            .padding(.bottom, 300),
            alignment: .bottomLeading
        )
        .fullScreenCover(isPresented: $showGoal) {
            GoalView()
        }
    }
    
    private func formattedBalance(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

#Preview {
    RewardClaimView(vm: BLEViewModel())
}
