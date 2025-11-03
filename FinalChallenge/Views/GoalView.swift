import SwiftUI
import SwiftData

struct GoalView: View {

    @StateObject private var vm = GoalViewModel()
    @Environment(\.modelContext) private var context

    // Penting: bikin init() sendiri agar tidak perlu 'init(goals:)'
    @Query private var goals: [GoalModel]
    init() {
        _goals = Query() // tanpa filter/sort; aman untuk preview & pemakaian umum
    }

    // State untuk Saving Input Modal
    @State private var showSavingModal = false
    @State private var savingAmountText = ""

    // Bottom items view model
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()

    // Circle steps view model
    @StateObject private var circleVM = CircleStepViewModel(totalSteps: 0, passedSteps: 0)

    // Warna
    private let boardBackground = Color(.sRGB, red: 0.08, green: 0.32, blue: 0.40)
    private let panelTeal        = Color(.sRGB, red: 0.02, green: 0.43, blue: 0.51)
    private let panelOverlay     = Color.white.opacity(0.10)
    private let buttonGreen      = Color(.sRGB, red: 0.73, green: 0.84, blue: 0.49)

    var body: some View {
        ZStack {
            boardBackground.ignoresSafeArea()

            // Panel utama
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(panelTeal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 34)
                            .stroke(panelOverlay, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 12)

                // Isi panel
                ZStack {
                    // 1) Scroll berisi tombol & stepping stones
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Button {
                                vm.onCircleTap()
                            } label: {
                                Text("Set New Goal")
                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .fill(buttonGreen)
                                            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 10)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 24)
                            .padding(.bottom, 16)

                            CircleStepView(
                                viewModel: circleVM
                            ) { step in
                                // 1) checkpoint/goal yang sudah dilewati → buka klaim
                                if (step.isCheckpoint || step.isGoal), step.id <= vm.passedSteps {
                                    vm.tryOpenClaim(for: step.id, context: context)
                                    return
                                }
                                // 2) goal besar → buka modal set goal
                                if step.isGoal {
                                    vm.onCircleTap()
                                    return
                                }
                                // 3) step biasa → no-op
                            }
                            .padding(.vertical, 60)
                            .padding(.bottom, 180) // ruang panel bawah
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        }
                        .padding(.horizontal, 12)
                    }

                    // 2) Kartu “My Saving”
                    VStack {
                        Spacer()
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
                        .padding(.leading, 24)
                        .padding(.bottom, 188)
                    }

                    // 3) Panel Reward bawah
                    VStack {
                        Spacer()
                        BottomItemSelectionView(viewModel: bottomItemsVM)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
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
                    }
                }
                .padding(20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)

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
            circleVM.update(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
        .onChange(of: goals) { newGoals in
            vm.updateGoals(newGoals)
            vm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(vm.rewardViewItems)
            // sync circle VM when goals change might affect totals
            circleVM.update(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
        .onChange(of: vm.totalSteps) { _ in
            circleVM.update(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
        .onChange(of: vm.passedSteps) { _ in
            circleVM.update(totalSteps: vm.totalSteps, passedSteps: vm.passedSteps)
        }
    }

    // Helper: cari RewardMeta dari item panel
    private func vmRewardMeta(for item: RewardViewData) -> RewardMeta? {
        let catalog = RewardCatalog.rewards(forTotalSteps: vm.totalSteps)
        return catalog.first(where: { $0.id == item.id })
    }
}

#Preview {
    GoalView() // sekarang aman; punya init() custom
}
