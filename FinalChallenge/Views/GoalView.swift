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
    @State private var showBLESettingsModal = false
    
    // Claim modal state
    @State private var showCircleClaimModal = false
    @State private var pendingCircleClaimStep: StepDisplayModel? = nil
    
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
            backgroundLayer
            mainContentLayer
            topBarLayer
            settingsButtonLayer
            robotAndChatLayer
            modalsLayer
        }
        .onAppear(perform: handleOnAppear)
        .onChange(of: goals) { _, newGoals in
            handleGoalsChange(newGoals)
        }
        .onChange(of: goalVm.passedSteps) { _, newSteps in
            handlePassedStepsChange(newSteps)
        }
        .onChange(of: bleVM.lastBalance) { _, newBalance in
            handleBalanceChange(Int(newBalance))
        }
        .onChange(of: goalVm.currentGoalIsClaimed) {
            chatVMHolder.vm?.updateMessage(goals: goals)
        }
    }
    
    // MARK: - Layer Views
    
    private var backgroundLayer: some View {
        Image("background_main")
            .resizable()
            .ignoresSafeArea()
    }
    
    private var mainContentLayer: some View {
        VStack {
            circleStepSection
            bottomItemsSection
        }
        .offset(y: 50)
        .padding(.horizontal, 40)
    }
    
    private var circleStepSection: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    circleStepContent
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 960)
        }
        .background(frameTopBackground)
    }
    
    private var circleStepContent: some View {
        CircleStepView(
            viewModel: circleVM,
            goalImage: currentGoalImage,
            leadingContent: { circleLeadingButtons },
            onTap: handleCircleStepTap
        )
        .padding(.vertical, 60)
        .padding(.bottom, 180)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .offset(y: circleStepOffset)
        .opacity(circleStepOpacity)
    }
    
    private var currentGoalImage: UIImage? {
        if let lastGoal = goals.last,
           let imageData = lastGoal.imageData,
           let uiImage = UIImage(data: imageData) {
            return uiImage
        }
        return nil
    }
    
    @ViewBuilder
    private var circleLeadingButtons: some View {
        if goals.isEmpty || goalVm.currentGoalIsClaimed {
            Button {
                SoundManager.shared.play(.buttonClick)
                goalVm.onCircleTap()
            } label: {
                Image("setGoalButton")
            }
            .padding(.bottom, -70)
            .zIndex(2)
        }
        
        if (goalVm.passedSteps >= goalVm.totalSteps && goalVm.totalSteps > 0) && !goalVm.currentGoalIsClaimed {
            Button {
                SoundManager.shared.play(.goalFinish)
                bleVM.sendResetToDevice()
                goalVm.currentGoalIsClaimed = true
            } label: {
                Image("unlockButton")
            }
            .padding(.bottom, -150)
            .zIndex(2)
        }
    }
    
    private var frameTopBackground: some View {
        Image("frame_top")
            .offset(y: frameTopOffset)
            .opacity(frameTopOpacity)
    }
    
    private var bottomItemsSection: some View {
        BottomItemSelectionView(viewModel: bottomItemsVM)
            .padding(.top, 50)
            .offset(y: bottomItemsOffset)
            .opacity(bottomItemsOpacity)
            .onAppear {
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
    
    private var topBarLayer: some View {
        HStack {
            Spacer()
            
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
            
            Spacer()
        }
        .offset(y: -530)
    }
    
    private var settingsButtonLayer: some View {
        Button {
            showBLESettingsModal = true
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 36))
                .foregroundColor(.white)
                .padding(10)
                .background(.yellowButton, in: Circle())
        }
        .offset(x: 420, y: -620)
    }
    
    private var robotAndChatLayer: some View {
        Group {
            Image("robot")
                .offset(x: -500 + robotOffset, y: 350 + robotFloatOffset)
                .rotationEffect(Angle(degrees: robotRotation))
                .opacity(robotOpacity)
            
            ChatBubbleView(model: chatModel)
                .offset(x: -300, y: 350)
                .scaleEffect(chatBubbleScale)
                .opacity(chatBubbleOpacity)
        }
    }
    
    @ViewBuilder
    private var modalsLayer: some View {
        if goalVm.showGoalModal {
            ShowGoalModalView(goalVm: goalVm, bottomItemsVM: bottomItemsVM)
        }
        
        if showBLESettingsModal {
            CenteredModal(isPresented: $showBLESettingsModal) {
                BLEConnectionModalView(
                    onCancel: { showBLESettingsModal = false }
                )
                .environmentObject(bleVM)
            }
            .zIndex(5)
        }
        
        if showCircleClaimModal, let step = pendingCircleClaimStep {
            CenteredModal(isPresented: $showCircleClaimModal) {
                if let meta = getRewardMeta(for: step.id) {
                    ClaimModalView(
                        title: meta.title,
                        imageBaseName: meta.imageName,
                        onClaim: {
                            handleClaimAction(for: meta)
                        }
                    )
                }
            }
            .zIndex(6)
        }
    }
    
    // MARK: - Event Handlers
    
    private func handleCircleStepTap(_ step: StepDisplayModel) {
        // Jika step adalah checkpoint/goal yang unlocked tapi belum di-claim, buka modal
        if (step.isCheckpoint || step.isGoal), step.isUnlocked, !step.isClaimed {
            pendingCircleClaimStep = step
            showCircleClaimModal = true
            return
        }
        
        // Legacy behavior untuk step yang sudah di-claim
        if (step.isCheckpoint || step.isGoal), step.id <= goalVm.passedSteps {
            goalVm.tryOpenClaim(for: step.id, context: context)
            return
        }
    }
    
    private func handleClaimAction(for meta: RewardModel) {
        goalVm.openClaim(for: meta, context: context)
        goalVm.confirmClaim(context: context)
        goalVm.loadRewardsForView(context: context)
        bottomItemsVM.setItems(goalVm.rewardViewItems)
        
        let currentGoalStepsList = goals.map { $0.totalSteps }
        let claimedSteps = goalVm.getClaimedSteps(context: context)
        circleVM.updateSteps(
            goalSteps: currentGoalStepsList,
            passedSteps: goalVm.passedSteps,
            claimedSteps: claimedSteps
        )
        
        showCircleClaimModal = false
        pendingCircleClaimStep = nil
    }
    
    private func handleOnAppear() {
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
        let claimedSteps = goalVm.getClaimedSteps(context: context)
        circleVM.updateSteps(goalSteps: goalStepsList, passedSteps: goalVm.passedSteps, claimedSteps: claimedSteps)
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
    
    private func handleGoalsChange(_ newGoals: [GoalModel]) {
        goalVm.updateGoals(newGoals, context: context)
        goalVm.loadRewardsForView(context: context)
        bottomItemsVM.setItems(goalVm.rewardViewItems)
        
        let newGoalStepsList = newGoals.map { $0.totalSteps }
        let claimedSteps = goalVm.getClaimedSteps(context: context)
        circleVM.updateSteps(goalSteps: newGoalStepsList, passedSteps: goalVm.passedSteps, claimedSteps: claimedSteps)
        chatVMHolder.vm?.updateMessage(goals: newGoals)
    }
    
    private func handlePassedStepsChange(_ newPassedSteps: Int) {
        let currentGoalStepsList = goals.map { $0.totalSteps }
        let claimedSteps = goalVm.getClaimedSteps(context: context)
        circleVM.updateSteps(goalSteps: currentGoalStepsList, passedSteps: newPassedSteps, claimedSteps: claimedSteps)
        chatVMHolder.vm?.updateMessage(goals: goals)
    }
    
    private func handleBalanceChange(_ newBalance: Int) {
        goalVm.updateProgressFromBLEBalance(Int64(newBalance), allGoals: goals, context: context)
        goalVm.loadRewardsForView(context: context)
        bottomItemsVM.setItems(goalVm.rewardViewItems)
        
        let currentGoalStepsList = goals.map { $0.totalSteps }
        let claimedSteps = goalVm.getClaimedSteps(context: context)
        circleVM.updateSteps(goalSteps: currentGoalStepsList, passedSteps: goalVm.passedSteps, claimedSteps: claimedSteps)
        chatVMHolder.vm?.updateMessage(goals: goals)
    }
    
    private func scrollToTarget(proxy: ScrollViewProxy) {
        // 1. Get all goals except active goals
        let previousGoals = goals.dropLast()
        
        // 2. Count total steps from passed goals
        let previousStepsCount = previousGoals.reduce(0) { $0 + $1.totalSteps }
        
        // 3. Determine target ID
        let targetStepID = previousStepsCount + 1
        
        print("Scrolling to step ID: \(targetStepID + 1)")
        
        withAnimation(.spring()) {
            proxy.scrollTo(targetStepID, anchor: .bottom)
        }
    }
    
    private func vmRewardMeta(for item: RewardState) -> RewardModel? {
        let catalog = RewardCatalog.rewards(forTotalSteps: goalVm.totalSteps)
        return catalog.first(where: { $0.id == item.id })
    }
    
    private func getRewardMeta(for stepId: Int) -> RewardModel? {
        let catalog = RewardCatalog.rewards(forTotalSteps: goalVm.totalSteps)
        return catalog.first(where: { $0.step == stepId })
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
