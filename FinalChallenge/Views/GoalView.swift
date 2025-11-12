import SwiftUI
import SwiftData
import Combine

struct GoalView: View {
    
    @StateObject private var goalVm = GoalViewModel()
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
    @StateObject private var circleVM = CircleStepViewModel(totalSteps: 0, passedSteps: 0)
    
    @StateObject private var streakManagerHolder = OptionalStreakManagerHolder()
    @Environment(\.modelContext) private var context
    @EnvironmentObject var bleVM: BLEViewModel
    
    @Query private var goals: [GoalModel]
    init() {
        _goals = Query()
    }
    
    @State private var showSavingModal = false
    @State private var savingAmountText = ""
    @State private var showStep3Modal = false
    
    var body: some View {
        ZStack {
            Image("background_main")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack() {
                            CircleStepView(
                                viewModel: circleVM
                            ) { step in
                                if (step.isCheckpoint || step.isGoal), step.id <= goalVm.passedSteps {
                                    goalVm.tryOpenClaim(for: step.id, context: context)
                                    return
                                }
                            }
                            .padding(.vertical, 60)
                            .padding(.bottom, 180)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        }
                        .padding(.horizontal, 12)
                    }
                    
                    // Button complete goal
                    if goalVm.passedSteps >= goalVm.totalSteps, goalVm.totalSteps > 0 {
                        VStack(spacing: 20) {
                            Text("Goal Complete!")
                                .font(.title.bold())
                                .foregroundColor(.white)
                            
                            Button {
                                bleVM.sendResetToDevice()
                                goalVm.resetProgress(context: context)
                            } label: {
                                Text("Take Your Money")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(18)
                                    .shadow(radius: 4)
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.bottom, 220)
                    }
                    
                    ZStack (alignment: .trailing) {
                        if let sm = bleVM.streakManager {
                                StreakView(streakManager: sm)
                                    .padding(.top, 10)
                            }
                        Spacer()
                        HStack {
                            SavingCardView(
                                title: "My Saving",
                                totalSaving: String(bleVM.lastBalance)
                            )
                            .onTapGesture {
                                savingAmountText = ""
                                showSavingModal = true
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 1100)
                .background(
                    RoundedRectangle(cornerRadius: 34)
                        .fill(.ultraThinMaterial)
                        .opacity(0.4)
                )
                
                // 3) Panel Reward bawah
                VStack {
                    ZStack (alignment: .topLeading){
                        BottomItemSelectionView(viewModel: bottomItemsVM)
                            .onAppear {
                                // Hook selection callback
                                bottomItemsVM.onSelect = { item in
                                    if item.state == .claimable,
                                       let meta = vmRewardMeta(for: item) {
                                        goalVm.openClaim(for: meta, context: context)
                                    }
                                }
                                // Initial load and sync items
                                goalVm.loadRewardsForView(context: context)
                                bottomItemsVM.setItems(goalVm.rewardViewItems)
                            }
                            .onChange(of: goalVm.passedSteps) { _, _ in
                                goalVm.loadRewardsForView(context: context)
                                bottomItemsVM.setItems(goalVm.rewardViewItems)
                            }
                            .onChange(of: goalVm.rewardViewItems) { _, newItems in
                                bottomItemsVM.setItems(newItems)
                            }
                    }
                }
                .padding(.vertical, 20)
            }
            .padding(40)
            
            // Hapus Modal Set Goal (Step 1 & 2) agar user tidak bisa set goal
            // if goalVm.showGoalModal { ... } -> dihilangkan
            
            // Modal Claim Reward
            if goalVm.showClaimModal, let meta = goalVm.pendingClaim {
                CenteredModal(isPresented: $goalVm.showClaimModal) {
                    BottomClaimModalView(
                        title: meta.title,
                        imageName: meta.imageName,
                        onCancel: { goalVm.cancelClaim() },
                        onClaim: {
                            goalVm.confirmClaim(context: context)
                            goalVm.loadRewardsForView(context: context)
                            bottomItemsVM.setItems(goalVm.rewardViewItems)
                        }
                    )
                }
                .zIndex(3)
            }
        }
        .onAppear {
            // Create StreakManager once when context is available
            if streakManagerHolder.manager == nil {
                streakManagerHolder.manager = StreakManager(context: context)
            }
            goalVm.updateGoals(goals, context: context)
            goalVm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(goalVm.rewardViewItems)
            // sync circle VM initial state
            circleVM.updateSteps(totalSteps: goalVm.totalSteps, passedSteps: goalVm.passedSteps)
            bleVM.setContext(context)
            bleVM.streakManager?.evaluateMissedDay(for: goalVm.savingDaysArray)
        }
        .onChange(of: goals) { _, newGoals in
            goalVm.updateGoals(newGoals, context: context)
            goalVm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(goalVm.rewardViewItems)
            circleVM.updateSteps(totalSteps: goalVm.totalSteps, passedSteps: goalVm.passedSteps)
        }
        .onChange(of: goalVm.totalSteps) { _, _ in
            circleVM.updateSteps(totalSteps: goalVm.totalSteps, passedSteps: goalVm.passedSteps)
        }
        .onChange(of: goalVm.passedSteps) { _, _ in
            circleVM.updateSteps(totalSteps: goalVm.totalSteps, passedSteps: goalVm.passedSteps)
        }
        // NEW: sinkronkan progress dari BLE (gunakan lastBalance kumulatif)
        .onChange(of: bleVM.lastBalance) { _, newBalance in
            goalVm.updateProgressFromBLEBalance(newBalance, context: context)
            goalVm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(goalVm.rewardViewItems)
            circleVM.updateSteps(totalSteps: goalVm.totalSteps, passedSteps: goalVm.passedSteps)
        }
    }
    
    // Helper: cari RewardMeta dari item panel
    private func vmRewardMeta(for item: RewardState) -> RewardModel? {
        let catalog = RewardCatalog.rewards(forTotalSteps: goalVm.totalSteps)
        return catalog.first(where: { $0.id == item.id })
    }
}

// Helper holder to allow optional @StateObject-like storage
final class OptionalStreakManagerHolder: ObservableObject {
    @Published var manager: StreakManager?
}

#Preview {
    GoalView().environmentObject(BLEViewModel())
}
