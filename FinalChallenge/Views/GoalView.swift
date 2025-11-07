import SwiftUI
import SwiftData

struct GoalView: View {
    
    @StateObject private var vm = GoalViewModel()
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
    @StateObject private var circleVM = CircleStepViewModel(totalSteps: 0, passedSteps: 0)

    @Environment(\.modelContext) private var context
    
    @Query private var goals: [GoalModel]
    init() {
        _goals = Query()
    }
    
    @State private var showSavingModal = false
    @State private var savingAmountText = ""
    @State private var isBottomVisible = true
    
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
                    
                    VStack {
                        HStack {
                            SavingCardView(
                                title: "My Saving",
                                totalSaving: vm.formattedTotalSaving
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
                                        vm.openClaim(for: meta, context: context)
                                    }
                                }
                                // Initial load and sync items
                                vm.loadRewardsForView(context: context)
                                bottomItemsVM.setItems(vm.rewardViewItems)
                            }
                            .onChange(of: vm.passedSteps) { _ in
                                vm.loadRewardsForView(context: context)
                                bottomItemsVM.setItems(vm.rewardViewItems)
                            }
                            .onChange(of: vm.rewardViewItems) { newItems in
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
                        onSave: { amount in
                            vm.applySaving(amount: amount)
                            showSavingModal = false
                            vm.loadRewardsForView(context: context)
                            bottomItemsVM.setItems(vm.rewardViewItems)
                        }
                    )
                }
                .zIndex(4)
            }
        }
        .onAppear {
            vm.updateGoals(goals)
            vm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(vm.rewardViewItems)
            // sync circle VM initial state
            circleVM.updateSteps(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
        .onChange(of: goals) { newGoals in
            vm.updateGoals(newGoals)
            vm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(vm.rewardViewItems)
            // sync circle VM when goals change might affect totals
            circleVM.updateSteps(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
        .onChange(of: vm.totalSteps) { _ in
            circleVM.updateSteps(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
        .onChange(of: vm.passedSteps) { _ in
            circleVM.updateSteps(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
    }
    
    // Helper: cari RewardMeta dari item panel
    private func vmRewardMeta(for item: RewardState) -> RewardModel? {
        let catalog = RewardCatalog.rewards(forTotalSteps: vm.totalSteps)
        return catalog.first(where: { $0.id == item.id })
    }
}

#Preview {
    GoalView() // sekarang aman; punya init() custom
}
