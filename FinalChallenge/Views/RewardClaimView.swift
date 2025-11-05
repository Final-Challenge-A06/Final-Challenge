import SwiftUI

struct RewardClaimView: View {
    @ObservedObject var vm: BLEViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Image("bgTrialDevice")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
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
                            .offset(y: -150)
                        
                        Text("3D GLASSES")
                            .font(.custom("Audiowide", size: 26))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                            .offset(y: -100)
                        
                        Image("glasses")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160)
                            .padding(.top, 4)
                            .offset(y: -75)
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.yellow)
                                .shadow(radius: 4)
                        }
                        .offset(y: -75)
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
            .padding(.leading, 100)
            .padding(.bottom, 175),
            alignment: .bottomLeading
        )
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
