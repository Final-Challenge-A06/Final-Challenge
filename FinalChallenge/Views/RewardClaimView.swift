//import SwiftUI
//
//struct RewardClaimView: View {
//    @ObservedObject var vm: BLEViewModel
//    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
//    
//    @Environment(\.dismiss) private var dismiss
//    @State private var showGoal = false
//    
//    var body: some View {
//        ZStack {
//            Image("bgTrialDevice")
//                .resizable()
//                .scaledToFill()
//                .edgesIgnoringSafeArea(.all)
//            
//            VStack {
//                ZStack {
//                    Image("rewardModal")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(maxWidth: 600)
//                        .offset(y: 100)
//                    
//                    VStack(spacing: 10) {
//                        Text("NEW ACCESSORIES")
//                            .font(.custom("Audiowide", size: 26))
//                            .foregroundColor(.white)
//                            .shadow(radius: 3)
//                        
//                        Text("3D GLASSES")
//                            .font(.custom("Audiowide", size: 26))
//                            .foregroundColor(.white)
//                            .shadow(radius: 3)
//                        
//                        Image("glasses")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 160)
//                            .padding(.top, 4)
//                        
//                        Button {
//                            showGoal = true
//                        } label: {
//                            Image(systemName: "checkmark.circle.fill")
//                                .font(.system(size: 48, weight: .bold))
//                                .foregroundColor(.yellow)
//                                .shadow(radius: 4)
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                }
//                
//                BottomItemSelectionView(viewModel: bottomItemsVM)
//                    .padding(.horizontal, 50)
//                    .offset(y: 150)
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.bottom, 120)
//        }
//        .overlay(
//            HStack {
//                SavingCardView(
//                    title: "My Saving",
//                    current: Int(vm.lastBalance),
//                    target: 180_000 // atau ambil dari GoalModel jika tersedia di layar ini
//                )
//            }
//                .offset(x: -320, y: 340)
//        )
//        .fullScreenCover(isPresented: $showGoal) {
//            GoalView()
//        }
//    }
//}
//
//#Preview {
//    RewardClaimView(vm: BLEViewModel())
//}
