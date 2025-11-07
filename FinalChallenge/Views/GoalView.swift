import SwiftUI
import SwiftData
import Combine

struct GoalView: View {
    
    @StateObject private var vm = GoalViewModel()
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
    @StateObject private var circleVM = CircleStepViewModel(totalSteps: 0, passedSteps: 0)

    // Defer creation until context is available
    @StateObject private var streakManagerHolder = OptionalStreakManagerHolder()
    @Environment(\.modelContext) private var context
    @EnvironmentObject var bleVM: BLEViewModel
    
    @Query private var goals: [GoalModel]
    init() {
        _goals = Query()
    }
    
    @State private var showSavingModal = false
    @State private var savingAmountText = ""
    @State private var isBottomVisible = true
    
    // Fallback color for the button if buttonGreen isn’t defined elsewhere
    private let buttonGreen = Color.green.opacity(0.8)
    
    var body: some View {
        ZStack {
            Image("bg_main")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack() {
                            Button {
                                vm.onCircleTap()
                            } label: {
                                SetGoalView()
                            }
                            
                            CircleStepView(
                                viewModel: circleVM
                            ) { step in
                                if (step.isCheckpoint || step.isGoal), step.id <= vm.passedSteps {
                                    vm.tryOpenClaim(for: step.id, context: context)
                                    return
                                }
                                
                                if step.isGoal {
                                    vm.onCircleTap()
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
                    if vm.passedSteps >= vm.totalSteps, vm.totalSteps > 0 {
                        VStack(spacing: 20) {
                            Text("Goal Complete!")
                                .font(.title.bold())
                                .foregroundColor(.white)
                            
                            Button {
                                bleVM.sendResetToDevice()
                                vm.resetProgress(context: context)
                            } label: {
                                Text("Take Your Money")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(buttonGreen)
                                    .cornerRadius(18)
                                    .shadow(radius: 4)
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.bottom, 220)
                    }
                    
                    ZStack (alignment: .trailing) {
                        if let streakManager = streakManagerHolder.manager {
                            StreakView(streakManager: streakManager)
                                .padding(.top, 10)
                        }
                        Spacer()
                        HStack {
                            SavingCardView(
                                title: "My Saving",
                                totalSaving: String(bleVM.lastBalance)
                            )
                            .onTapGesture {
                                // Optional: kamu bisa tetap tampilkan modal, tapi tidak memengaruhi progress
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
                                        vm.openClaim(for: meta, context: context)
                                    }
                                }
                                // Initial load and sync items
                                vm.loadRewardsForView(context: context)
                                bottomItemsVM.setItems(vm.rewardViewItems)
                            }
                            .onChange(of: vm.passedSteps) {
                                vm.loadRewardsForView(context: context)
                                bottomItemsVM.setItems(vm.rewardViewItems)
                            }
                            .onChange(of: vm.rewardViewItems) { _, newItems in
                                bottomItemsVM.setItems(newItems)
                            }
                        
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                isBottomVisible.toggle()
                            }
                        } label: {
                            Image(systemName: "book.closed.fill")
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 20)
                .offset(y: isBottomVisible ? 0 : 100)
            }
            .padding(40)
            
            // Modal Set Goal
            if vm.showGoalModal {
                CenteredModal(isPresented: $vm.showGoalModal) {
                    if vm.activeStep == 1 {
                        GoalModalStep1View(
                            vm: vm,
                            onNext: { vm.goToNextStep() },
                            onClose: { vm.closeModal() }
                        )
                    } else {
                        GoalModalStep2View(
                            vm: vm,
                            onDone: {
                                vm.saveGoal(context: context)
                                // Segera refresh reward dan sinkronkan ke panel bawah
                                vm.loadRewardsForView(context: context)
                                bottomItemsVM.setItems(vm.rewardViewItems)
                                vm.closeModal()
                            },
                            onBack: { vm.activeStep = 1 }
                        )
                    }
                }
                .zIndex(2)
            }
            
            // Modal Claim Reward
            if vm.showClaimModal, let meta = vm.pendingClaim {
                CenteredModal(isPresented: $vm.showClaimModal) {
                    BottomClaimModalView(
                        title: meta.title,
                        imageName: meta.imageName,
                        onCancel: { vm.cancelClaim() },
                        onClaim: {
                            vm.confirmClaim(context: context)
                            vm.loadRewardsForView(context: context)
                            bottomItemsVM.setItems(vm.rewardViewItems)
                        }
                    )
                }
                .zIndex(3)
            }
            
            // Modal Input Saving
            if showSavingModal {
                CenteredModal(isPresented: $showSavingModal) {
                    SavingInputModalView(
                        title: "Add Saving",
                        amountText: $savingAmountText,
                        onCancel: { showSavingModal = false },
                        onSave: { _ in
                            // Tidak lagi mengubah progress dari modal.
                            showSavingModal = false
                            // Jika ingin, bisa tetap refresh UI, tapi tidak perlu mengubah vm.
                            vm.loadRewardsForView(context: context)
                            bottomItemsVM.setItems(vm.rewardViewItems)
                        }
                    )
                }
                .zIndex(4)
            }
        }
        .onAppear {
            // Create StreakManager once when context is available
            if streakManagerHolder.manager == nil {
                streakManagerHolder.manager = StreakManager(context: context)
            }
            vm.updateGoals(goals, context: context)
            vm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(vm.rewardViewItems)
            // sync circle VM initial state
            circleVM.updateSteps(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
        .onChange(of: goals) { newGoals in
            vm.updateGoals(newGoals, context: context)
            vm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(vm.rewardViewItems)
            circleVM.updateSteps(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
        .onChange(of: vm.totalSteps) {
            circleVM.updateSteps(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
        .onChange(of: vm.passedSteps) {
            circleVM.updateSteps(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
        // NEW: sinkronkan progress dari BLE (gunakan lastBalance kumulatif)
        .onChange(of: bleVM.lastBalance) { _, newBalance in
            vm.updateProgressFromBLEBalance(newBalance, context: context)
            vm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(vm.rewardViewItems)
            circleVM.updateSteps(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
    }
    
    // Helper: cari RewardMeta dari item panel
    private func vmRewardMeta(for item: RewardState) -> RewardModel? {
        let catalog = RewardCatalog.rewards(forTotalSteps: vm.totalSteps)
        return catalog.first(where: { $0.id == item.id })
    }
}

// Helper holder to allow optional @StateObject-like storage
final class OptionalStreakManagerHolder: ObservableObject {
    @Published var manager: StreakManager?
}

#Preview {
    GoalView()
        .environmentObject(BLEViewModel())
}
