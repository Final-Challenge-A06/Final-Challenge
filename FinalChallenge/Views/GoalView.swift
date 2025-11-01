import SwiftUI
import SwiftData

struct GoalView: View {
    
    @StateObject private var vm = GoalViewModel()
    @Environment(\.modelContext) private var context
    
    // View tetap memegang @Query, lalu diteruskan ke VM
    @Query var goals: [GoalModel]
    
    // Warna-warna yang mendekati mockup
    private let boardBackground = Color(.sRGB, red: 0.08, green: 0.32, blue: 0.40)
    private let panelTeal = Color(.sRGB, red: 0.02, green: 0.43, blue: 0.51)
    private let panelOverlay = Color.white.opacity(0.10)
    private let buttonGreen = Color(.sRGB, red: 0.73, green: 0.84, blue: 0.49)

    // State untuk modal "My Saving"
    @State private var showSavingModal: Bool = false
    @State private var savingAmountText: String = ""
    
    var body: some View {
        ZStack {
            // Latar belakang besar
            boardBackground.ignoresSafeArea()
            
            // Panel utama ber-radius besar seperti mockup
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
                    // 1) Deretan platform/circle + tombol "Set New Goals" di dalam ScrollView agar ikut scroll
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Tombol “Set New Goals” diletakkan di bagian atas konten scroll
                            Button {
                                vm.onCircleTap()
                            } label: {
                                Text("Set New Goals")
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
                                totalSteps: vm.totalSteps,
                                passedSteps: vm.passedSteps
                            ) { step in
                                // 1) Jika checkpoint/goal dan sudah passed -> buka modal klaim
                                if (step.isCheckpoint || step.isGoal) && step.id <= vm.passedSteps {
                                    vm.tryOpenClaim(for: step.id, context: context)
                                    return
                                }
                                // 2) Jika yang ditekan adalah Goal besar (bukan kondisi klaim) -> buka modal set goal
                                if step.isGoal {
                                    vm.onCircleTap()
                                    return
                                }
                                // 3) Circle biasa: tidak melakukan apa-apa (jangan buka modal)
                            }
                            .padding(.vertical, 60)
                            .padding(.bottom, 180) // beri ruang untuk panel bawah
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        }
                    }
                    
                    // 4) Kartu “My Saving” (modular component)
                    VStack {
                        Spacer()
                        HStack {
                            SavingCardView(
                                title: "My Saving",
                                amountText: "10.000"
                            )
                            .onTapGesture {
                                savingAmountText = ""
                                withAnimation { showSavingModal = true }
                            }
                            Spacer()
                        }
                        .padding(.leading, 24)
                        .padding(.bottom, 188) // ruang untuk panel bawah
                    }

                    // 5) Panel Reward di bawah
                    VStack {
                        Spacer()
                        BottomItemSelectionView(items: vm.rewardViewItems) { item in
                            // kalau claimable dari panel, tampilkan modal klaim juga
                            if item.state == .claimable,
                               let meta = vmRewardMeta(for: item) {
                                vm.openClaim(for: meta, context: context)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                        .onAppear {
                            vm.loadRewardsForView(context: context)
                        }
                        .onChange(of: vm.passedSteps) { _ in
                            vm.loadRewardsForView(context: context)
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
                        }
                    )
                }
                .zIndex(3)
            }

            // Modal "My Saving" input nominal
            if showSavingModal {
                CenteredModal(isPresented: $showSavingModal) {
                    SavingInputModalView(
                        amountText: $savingAmountText,
                        onCancel: {
                            withAnimation { showSavingModal = false }
                        },
                        onSave: { amount in
                            // TODO: sambungkan ke logic penyimpanan/progress
                            print("Nominal nabung hari ini:", amount)
                            withAnimation { showSavingModal = false }
                        }
                    )
                }
                .zIndex(4)
            }
        }
        .onAppear {
            vm.updateGoals(goals)
            vm.loadRewardsForView(context: context)
        }
        .onChange(of: goals) { newGoals in
            vm.updateGoals(newGoals)
            vm.loadRewardsForView(context: context)
        }
    }

    // Helper untuk mencari RewardMeta dari item panel
    private func vmRewardMeta(for item: RewardViewData) -> RewardMeta? {
        // mapping sederhana: cari berdasarkan id
        let catalog = RewardCatalog.rewards(forTotalSteps: vm.totalSteps)
        return catalog.first(where: { $0.id == item.id })
    }
}

#Preview {
    GoalView()
}
