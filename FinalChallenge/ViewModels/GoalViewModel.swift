//
//  GoalViewModel.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI
import PhotosUI
import Combine
import SwiftData

@MainActor
final class GoalViewModel: ObservableObject {
    // MARK: - Step 1 Fields
    @Published private var _goalName: String = ""
    @Published private var _priceText: Int = 0
    @Published var selectedItem: PhotosPickerItem? = nil
    @Published var selectedImage: UIImage? = nil
    
    // MARK: - Step 2 Fields
    @Published var selectedDays: Set<String> = []
    @Published private var _amountText: Int = 0
    
    // MARK: - Modal & Flow State
    @Published var showGoalModal: Bool = false
    @Published var activeStep: Int = 1
    
    // MARK: - Reward Claim Modal
    @Published var showClaimModal: Bool = false
    @Published private(set) var pendingClaim: RewardModel? = nil
    
    // MARK: - Steps Output untuk UI
    @Published private(set) var totalSteps: Int = 0
    @Published private(set) var passedSteps: Int = 0
    
    // MARK: - Source data dari @Query
    private var latestGoal: GoalModel? = nil
    private var currentProgress: SavingProgressEntity?
    
    // MARK: - Rewards
    @Published private(set) var rewardViewItems: [RewardState] = []
    private var rewardCatalog: [RewardModel] = []
    
    // MARK: - Saving
    @Published private(set) var totalSaving: Int = 0
    var formattedTotalSaving: String {
        numberFormatter.string(from: NSNumber(value: totalSaving)) ?? "\(totalSaving)"
    }
    private let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.groupingSeparator = "."
        nf.decimalSeparator = ","
        return nf
    }()
    
    // MARK: - Getter Setter
    var goalName: String {
        get { _goalName }
        set {
            _goalName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            validateStep1()
        }
    }
    
    var priceText: String {
        get { _priceText == 0 ? "" : "\(_priceText)" }
        set {
            _priceText = Int(newValue) ?? 0
            validateStep1()
        }
    }
    
    var amountText: String {
        get { _amountText == 0 ? "" : "\(_amountText)" }
        set {
            _amountText = Int(newValue) ?? 0
            validateStep2()
        }
    }
    
    var savingDaysArray: [String] {
        Array(selectedDays)
    }
    
    // MARK: - Validation Logic
    @Published var isStep1Valid: Bool = false
    @Published var isStep2Valid: Bool = false
    
    func validateStep1() {
        isStep1Valid = !goalName.trimmingCharacters(in: .whitespaces).isEmpty && _priceText > 0 && selectedImage != nil
    }
    
    func validateStep2() {
        isStep2Valid = !selectedDays.isEmpty && _amountText > 0
    }
    
    // MARK: - Save Goal
    func saveGoal(context: ModelContext) {
        guard !goalName.isEmpty,
              Int(priceText) != nil,
              Int(amountText) != nil,
              !selectedDays.isEmpty else {
            print("❌ Tidak bisa simpan, data belum lengkap")
            return
        }
        
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        let goal = GoalModel(
            name: goalName,
            targetPrice: _priceText,
            imageData: imageData,
            savingDays: Array(selectedDays),
            amountPerSave: _amountText
        )
        context.insert(goal)
        
        do {
            try context.save()
            print("✅ Berhasil simpan goal:", goal.name)
            
            // Buat progress entity baru untuk goal ini
            latestGoal = goal
            totalSteps = goal.totalSteps
            
            let progressEntity = SavingProgressEntity(
                goalID: goal.name,
                totalSaving: 0,
                passedSteps: 0
            )
            context.insert(progressEntity)
            try context.save()
            
            currentProgress = progressEntity
            passedSteps = 0
            totalSaving = 0
            
            // Refresh katalog reward
            rewardCatalog = RewardCatalog.rewards(forTotalSteps: totalSteps)
        } catch {
            print("❌ Gagal simpan:", error.localizedDescription)
        }
    }
    
    // MARK: - Load Progress dari SwiftData
    func loadProgress(for goal: GoalModel, context: ModelContext) {
        // Capture the goalID as a concrete value so the predicate rhs is not a key path
        let goalID = goal.name
        let descriptor = FetchDescriptor<SavingProgressEntity>(
            predicate: #Predicate { $0.goalID == goalID }
        )
        
        do {
            if let progress = try context.fetch(descriptor).first {
                currentProgress = progress
                totalSaving = progress.totalSaving
                passedSteps = progress.passedSteps
            } else {
                // Buat progress baru jika belum ada
                let newProgress = SavingProgressEntity(goalID: goal.name)
                context.insert(newProgress)
                try context.save()
                currentProgress = newProgress
                totalSaving = 0
                passedSteps = 0
            }
        } catch {
            print("❌ Load progress failed:", error.localizedDescription)
        }
    }
    
    // MARK: - Save Progress ke SwiftData
    private func saveProgress(context: ModelContext) {
        guard let progress = currentProgress else { return }
        
        progress.totalSaving = totalSaving
        progress.passedSteps = passedSteps
        progress.updatedAt = Date()
        
        do {
            try context.save()
            print("✅ Progress saved: totalSaving=\(totalSaving), passedSteps=\(passedSteps)")
        } catch {
            print("❌ Save progress failed:", error.localizedDescription)
        }
    }
    
    // MARK: - Update Goals
    func updateGoals(_ goals: [GoalModel], context: ModelContext) {
        let previousGoalId = latestGoal?.name
        latestGoal = goals.last
        
        if let goal = latestGoal {
            totalSteps = goal.totalSteps
            
            // Load progress dari SwiftData
            if previousGoalId != goal.name {
                loadProgress(for: goal, context: context)
            }
        } else {
            totalSteps = 0
            passedSteps = 0
            totalSaving = 0
            currentProgress = nil
        }
        
        // Refresh catalog & view items
        rewardCatalog = RewardCatalog.rewards(forTotalSteps: totalSteps)
    }
    
    // MARK: - Circle Tap
    func onCircleTap() {
        activeStep = 1
        showGoalModal = true
    }
    
    // MARK: - Reward Claim Flow
    func tryOpenClaim(for step: Int, context: ModelContext) {
        guard let meta = rewardCatalog.first(where: { $0.step == step }) else { return }
        guard step <= passedSteps else { return }
        let alreadyClaimed = fetchRewardEntity(id: meta.id, context: context)?.claimed == true
        guard !alreadyClaimed else { return }
        
        pendingClaim = meta
        showClaimModal = true
    }
    
    func openClaim(for meta: RewardModel, context: ModelContext) {
        guard meta.step <= passedSteps else { return }
        let alreadyClaimed = fetchRewardEntity(id: meta.id, context: context)?.claimed == true
        guard !alreadyClaimed else { return }
        pendingClaim = meta
        showClaimModal = true
    }
    
    func confirmClaim(context: ModelContext) {
        guard let meta = pendingClaim else { return }
        if let existing = fetchRewardEntity(id: meta.id, context: context) {
            existing.claimed = true
            existing.claimedAt = Date()
        } else {
            let entity = RewardEntity(
                id: meta.id,
                unlockedAtStep: meta.step,
                imageName: meta.imageName,
                title: meta.title,
                claimed: true,
                claimedAt: Date()
            )
            context.insert(entity)
        }
        do {
            try context.save()
        } catch {
            print("❌ Save reward failed:", error.localizedDescription)
        }
        showClaimModal = false
        pendingClaim = nil
    }
    
    func cancelClaim() {
        showClaimModal = false
        pendingClaim = nil
    }
    
    func loadRewardsForView(context: ModelContext) {
        let entities = fetchAllRewards(context: context)
        rewardViewItems = rewardCatalog.map { meta in
            if let ent = entities.first(where: { $0.id == meta.id }) {
                return RewardState(
                    id: ent.id,
                    title: ent.title,
                    imageName: ent.imageName,
                    state: ent.claimed ? .claimed : (meta.step <= passedSteps ? .claimable : .locked)
                )
            } else {
                return RewardState(
                    id: meta.id,
                    title: meta.title,
                    imageName: meta.imageName,
                    state: meta.step <= passedSteps ? .claimable : .locked
                )
            }
        }
    }
    
    // MARK: - SwiftData helpers
    private func fetchAllRewards(context: ModelContext) -> [RewardEntity] {
        do {
            let descriptor = FetchDescriptor<RewardEntity>()
            return try context.fetch(descriptor)
        } catch {
            print("❌ Fetch rewards failed:", error.localizedDescription)
            return []
        }
    }
    
    private func fetchRewardEntity(id: String, context: ModelContext) -> RewardEntity? {
        do {
            let descriptor = FetchDescriptor<RewardEntity>(predicate: #Predicate { $0.id == id })
            return try context.fetch(descriptor).first
        } catch {
            print("❌ Fetch reward by id failed:", error.localizedDescription)
            return nil
        }
    }
    
    // MARK: - Navigasi modal goal
    func goToNextStep() { activeStep = 2 }
    func closeModal() { showGoalModal = false }
    
    // MARK: - Progress update dengan SwiftData
    func applySaving(amount: Int, context: ModelContext) {
        guard amount > 0 else { return }
        totalSaving += amount
        recalcPassedStepsFromSaving()
        saveProgress(context: context)
    }
    
    private func recalcPassedStepsFromSaving() {
        guard let goal = latestGoal, goal.amountPerSave > 0 else {
            passedSteps = 0
            return
        }
        let stepsBySaving = totalSaving / goal.amountPerSave
        let clamped = min(stepsBySaving, totalSteps)
        if clamped != passedSteps {
            passedSteps = clamped
        }
    }
    
    func resetProgress(context: ModelContext) {
        totalSaving = 0
        passedSteps = 0
        saveProgress(context: context)
    }
    
    // MARK: - Update lastBalance ke SwiftData
    func updateLastBalance(_ balance: Int64, context: ModelContext) {
        guard let progress = currentProgress else { return }
        progress.lastBalance = balance
        do {
            try context.save()
        } catch {
            print("❌ Update balance failed:", error.localizedDescription)
        }
    }
}
