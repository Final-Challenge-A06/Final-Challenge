import SwiftUI
import SwiftData
import Combine

struct GoalView: View {
    
    @StateObject private var goalVm = GoalViewModel()
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
    @StateObject private var circleVM = CircleStepViewModel(goalSteps: [], passedSteps: 0)
    
    // Chat dependencies
    @StateObject private var chatModel = ChatModel()
    @StateObject private var chatVMHolder = ChatVMHolder()
    
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
    
    // Animation states
    @State private var savingCardOffset: CGFloat = -200
    @State private var savingCardOpacity: Double = 0
    @State private var streakViewOffset: CGFloat = 200
    @State private var streakViewOpacity: Double = 0
    @State private var circleStepOffset: CGFloat = 100
    @State private var circleStepOpacity: Double = 0
    @State private var bottomItemsOffset: CGFloat = 300
    @State private var bottomItemsOpacity: Double = 0
    @State private var robotOffset: CGFloat = -100
    @State private var robotOpacity: Double = 0
    @State private var robotFloatOffset: CGFloat = 0
    @State private var robotRotation: Double = -10
    @State private var chatBubbleScale: Double = 0
    @State private var chatBubbleOpacity: Double = 0
    @State private var frameTopOffset: CGFloat = -50
    @State private var frameTopOpacity: Double = 0
    
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
                            .offset(y: circleStepOffset)
                            .opacity(circleStepOpacity)
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
                        .offset(y: frameTopOffset)
                        .opacity(frameTopOpacity)
                )
                .offset(y: 80)
                
                BottomItemSelectionView(viewModel: bottomItemsVM)
                    .padding(.top, 50)
                    .offset(y: bottomItemsOffset)
                    .opacity(bottomItemsOpacity)
                    .onAppear {
                        bottomItemsVM.onSelect = { item in
                            if item.state == .claimable,
                               let meta = vmRewardMeta(for: item) {
                                goalVm.openClaim(for: meta, context: context)
                                
                                // Tandai event klaim untuk chat
                                if let activeGoal = goals.last {
                                    if meta.step == 1 {
                                        chatVMHolder.vm?.markJustClaimedFirstReward()
                                    } else if meta.step != activeGoal.totalSteps, meta.step % 7 == 0 {
                                        chatVMHolder.vm?.markJustClaimedCheckpoint()
                                    }
                                    chatVMHolder.vm?.updateMessage(goals: goals)
                                }
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
                .offset(x: savingCardOffset)
                .opacity(savingCardOpacity)
                
                if let sm = bleVM.streakManager {
                    StreakView(streakManager: sm)
                        .offset(x: streakViewOffset)
                        .opacity(streakViewOpacity)
                }
            }
            .offset(y: -530)
            
            Image("robot")
                .offset(x: -500 + robotOffset, y: 350 + robotFloatOffset)
                .rotationEffect(Angle(degrees: robotRotation))
                .opacity(robotOpacity)
            
            // Ganti Text statis menjadi ChatBubbleView dengan model chatModel
            ChatBubbleView(model: chatModel)
                .offset(x: -300, y: 350)
                .scaleEffect(chatBubbleScale)
                .opacity(chatBubbleOpacity)
        }
        .onAppear {
            // Buat StreakManager sekali
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
            
            // Inisialisasi ChatViewModel setelah bleVM tersedia dari Environment
            if chatVMHolder.vm == nil {
                chatVMHolder.vm = ChatViewModel(chat: chatModel, goalVM: goalVm, bleVM: bleVM)
            }
            chatVMHolder.vm?.updateMessage(goals: goals)
            
            // Start entrance animations
            startEntranceAnimations()
        }
        .onChange(of: goals) { _, newGoals in
            goalVm.updateGoals(newGoals, context: context)
            goalVm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(goalVm.rewardViewItems)
            let newGoalStepsList = newGoals.map { $0.totalSteps }
            circleVM.updateSteps(goalSteps: newGoalStepsList, passedSteps: goalVm.passedSteps)
            chatVMHolder.vm?.updateMessage(goals: newGoals)
        }
        .onChange(of: goalVm.passedSteps) { _, newPassedSteps in
            let currentGoalStepsList = goals.map { $0.totalSteps }
            circleVM.updateSteps(goalSteps: currentGoalStepsList, passedSteps: newPassedSteps)
            chatVMHolder.vm?.updateMessage(goals: goals)
        }
        .onChange(of: bleVM.lastBalance) { _, newBalance in
            goalVm.updateProgressFromBLEBalance(newBalance, allGoals: goals, context: context)
            goalVm.loadRewardsForView(context: context)
            bottomItemsVM.setItems(goalVm.rewardViewItems)
            let currentGoalStepsList = goals.map { $0.totalSteps }
            circleVM.updateSteps(goalSteps: currentGoalStepsList, passedSteps: goalVm.passedSteps)
            chatVMHolder.vm?.updateMessage(goals: goals)
        }
        .onChange(of: goalVm.currentGoalIsClaimed) { _, _ in
            chatVMHolder.vm?.updateMessage(goals: goals)
        }
    }
    
    private func vmRewardMeta(for item: RewardState) -> RewardModel? {
        let catalog = RewardCatalog.rewards(forTotalSteps: goalVm.totalSteps)
        return catalog.first(where: { $0.id == item.id })
    }
    
    private func startEntranceAnimations() {
        // Frame top slide down from top
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
            frameTopOffset = 0
            frameTopOpacity = 1
        }
        
        // Saving card slide in from left
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.3)) {
            savingCardOffset = 0
            savingCardOpacity = 1
        }
        
        // Streak view slide in from right
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.5)) {
            streakViewOffset = 0
            streakViewOpacity = 1
        }
        
        // Circle step view slide up from bottom
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4)) {
            circleStepOffset = 0
            circleStepOpacity = 1
        }
        
        // Bottom items slide up from bottom
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.6)) {
            bottomItemsOffset = 0
            bottomItemsOpacity = 1
        }
        
        // Robot slide in from left
        withAnimation(.spring(response: 0.9, dampingFraction: 0.7).delay(0.7)) {
            robotOffset = 0
            robotOpacity = 1
        }
        
        // Robot floating animation (continuous)
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(1.0)) {
            robotFloatOffset = -15
        }
        
        // Robot subtle rotation (continuous)
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(1.0)) {
            robotRotation = -5
        }
        
        // Chat bubble pop in with scale
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(1.0)) {
            chatBubbleScale = 1.0
            chatBubbleOpacity = 1
        }
    }
}

final class OptionalStreakManagerHolder: ObservableObject {
    @Published var manager: StreakManager?
}

// Holder untuk ChatViewModel agar bisa dibuat setelah bleVM tersedia dari Environment
final class ChatVMHolder: ObservableObject {
    @Published var vm: ChatViewModel?
}

#Preview {
    GoalView().environmentObject(BLEViewModel())
}

