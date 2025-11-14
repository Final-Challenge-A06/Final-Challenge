import SwiftUI
import SwiftData
import Combine

struct GoalView: View {
    
    @StateObject private var goalVm = GoalViewModel()
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
    @StateObject private var circleVM = CircleStepViewModel(goalSteps: [], passedSteps: 0)
    
    @StateObject private var streakManagerHolder = OptionalStreakManagerHolder()
    @Environment(\.modelContext) private var context
    @EnvironmentObject var bleVM: BLEViewModel
    
    @Query private var goals: [GoalModel]
    init() {
        _goals = Query()
    }
    
    @State private var showSavingModal = false
    @State private var savingAmountText = ""
    
    // Starter reward path (first money only)
    @AppStorage("hasCompletedTrial") private var hasCompletedTrial: Bool = false
    @State private var showStarterClaim = false
    @State private var showStarterReward = false
    
    var body: some View {
        ZStack {
            Image("background_main")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack() {
                            if goals.isEmpty || goalVm.currentGoalIsClaimed {
                                Button {
                                    goalVm.onCircleTap()
                                } label: {
                                    SetGoalView()
                                }
                            }
                            
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
                    .frame(height: 960)
                    
                    // Button complete goal
                    // Menampilkan HANYA jika goal selesai DAN BELUM DI-KLAIM
                    if (goalVm.passedSteps >= goalVm.totalSteps && goalVm.totalSteps > 0) && !goalVm.currentGoalIsClaimed {
                        VStack(spacing: 20) {
                            Text("Goal Complete!")
                                .font(.title.bold())
                                .foregroundColor(.white)
                            
                            Button {
                                bleVM.sendResetToDevice()
                                goalVm.currentGoalIsClaimed = true
//                                goalVm.resetProgress(context: context)
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
                }
                .background(
                    Image("frame_top")
                )
                
                BottomItemSelectionView(viewModel: bottomItemsVM)
                    .padding(.top, 50)
                    .onAppear {
                        bottomItemsVM.onSelect = { item in
                            if item.state == .claimable,
                               let meta = vmRewardMeta(for: item) {
                                goalVm.openClaim(for: meta, context: context)
                            }
                        }
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
            .offset(y: 50)
            .padding(.horizontal, 40)
            
            HStack {
                SavingCardView(
                    title: goals.last?.name ?? "Hirono Blindbox",
                    current: goalVm.totalSaving,
                    target: goals.last?.targetPrice ?? 0
                )
                .padding(.trailing, 20)
                
                if let sm = bleVM.streakManager {
                    StreakView(streakManager: sm)
                }
            }
            .offset(y: -530)
            
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
                            circleVM.updateSteps(
                                totalSteps: goalVm.totalSteps,
                                passedSteps: goalVm.passedSteps
                            )
                        }
                    )
                }
                .zIndex(4)
            }
        }
        .onAppear {
            // Create StreakManager once when context is available
            bleVM.setContext(context)
            if streakManagerHolder.manager == nil {
                streakManagerHolder.manager = StreakManager(context: context)
            }
            goalVm.updateGoals(goals, context: context)
            goalVm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(goalVm.rewardViewItems)
            // sync circle VM initial state
            let goalStepsList = goals.map { $0.totalSteps }
            circleVM.updateSteps(goalSteps: goalStepsList, passedSteps: goalVm.passedSteps)
            bleVM.setContext(context)
            bleVM.streakManager?.evaluateMissedDay(for: goalVm.savingDaysArray)
        }
        .onChange(of: goals) { _, newGoals in
            goalVm.updateGoals(newGoals, context: context)
            goalVm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(goalVm.rewardViewItems)
            let newGoalStepsList = newGoals.map { $0.totalSteps }
            circleVM.updateSteps(goalSteps: newGoalStepsList, passedSteps: goalVm.passedSteps)
        }
//        .onChange(of: goalVm.totalSteps) { _, _ in
//            circleVM.updateSteps(totalSteps: goalVm.totalSteps, passedSteps: goalVm.passedSteps)
//        }
        .onChange(of: goalVm.passedSteps) { _, newPassedSteps in
            let currentGoalStepsList = goals.map { $0.totalSteps }
            circleVM.updateSteps(goalSteps: currentGoalStepsList, passedSteps: newPassedSteps)
        }
        .onChange(of: bleVM.lastBalance) { _, newBalance in
            goalVm.updateProgressFromBLEBalance(newBalance, allGoals: goals, context: context)
            goalVm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(goalVm.rewardViewItems)
            let currentGoalStepsList = goals.map { $0.totalSteps }
            circleVM.updateSteps(goalSteps: currentGoalStepsList, passedSteps: goalVm.passedSteps)
        }
    }
    
    private func vmRewardMeta(for item: RewardState) -> RewardModel? {
        let catalog = RewardCatalog.rewards(forTotalSteps: goalVm.totalSteps)
        return catalog.first(where: { $0.id == item.id })
    }
}

final class OptionalStreakManagerHolder: ObservableObject {
    @Published var manager: StreakManager?
}

#Preview {
    GoalView().environmentObject(BLEViewModel())
}
