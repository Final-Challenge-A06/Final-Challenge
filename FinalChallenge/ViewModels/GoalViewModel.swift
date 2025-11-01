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

protocol GoalSaving {
    func insert(_ goal: GoalModel)
    func save() throws
}

extension ModelContext: GoalSaving {
    func insertGoal(_ goal: GoalModel) {
        insert(goal)
    }
}

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
    @Published private(set) var pendingClaim: RewardMeta? = nil
    
    // MARK: - Steps Output untuk UI
    @Published private(set) var totalSteps: Int = 7
    @Published private(set) var passedSteps: Int = 0
    
    // MARK: - Source data dari @Query (dioper dari View)
    private var latestGoal: GoalModel? = nil

    // MARK: - Rewards (SwiftData)
    @Published private(set) var rewardViewItems: [RewardViewData] = []
    private var rewardCatalog: [RewardMeta] = []
    
    // MARK: - Public computed accessors
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
    func saveGoal(context: GoalSaving) {
        guard !goalName.isEmpty,
              Int(priceText) != nil,
              Int(amountText) != nil,
              !selectedDays.isEmpty else {
            print("Tidak bisa simpan, data belum lengkap")
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
            print("Berhasil simpan goal:", goal.name)
        } catch {
            print("Gagal simpan:", error.localizedDescription)
        }
    }
    
    // MARK: - Logic dari View
    func updateGoals(_ goals: [GoalModel]) {
        latestGoal = goals.last
        if let goal = latestGoal {
            totalSteps = goal.totalSteps
        } else {
            totalSteps = 7
        }
        // TODO: ganti dengan progress real
        passedSteps = 0

        // refresh catalog & view items
        rewardCatalog = RewardCatalog.rewards(forTotalSteps: totalSteps)
    }
    
    // Dipanggil oleh View untuk membuka modal goal
    func onCircleTap() {
        activeStep = 1
        showGoalModal = true
    }

    // MARK: - Reward Claim Flow
    func tryOpenClaim(for step: Int, context: ModelContext) {
        // hanya checkpoint di catalog
        guard let meta = rewardCatalog.first(where: { $0.step == step }) else { return }
        // hanya jika step sudah passed
        guard step <= passedSteps else { return }
        // cek apakah sudah diklaim
        let alreadyClaimed = fetchRewardEntity(id: meta.id, context: context)?.claimed == true
        guard !alreadyClaimed else { return }

        pendingClaim = meta
        showClaimModal = true
    }

    func openClaim(for meta: RewardMeta, context: ModelContext) {
        // ensure step is passed
        guard meta.step <= passedSteps else { return }
        // prevent duplicate claim
        let alreadyClaimed = fetchRewardEntity(id: meta.id, context: context)?.claimed == true
        guard !alreadyClaimed else { return }
        pendingClaim = meta
        showClaimModal = true
    }

    func confirmClaim(context: ModelContext) {
        guard let meta = pendingClaim else { return }
        // upsert entity
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
        // Buat 3 slot dari catalog
        rewardViewItems = rewardCatalog.map { meta in
            if let ent = entities.first(where: { $0.id == meta.id }) {
                return RewardViewData(
                    id: ent.id,
                    title: ent.title,
                    imageName: ent.imageName,
                    state: ent.claimed ? .claimed : (meta.step <= passedSteps ? .claimable : .locked)
                )
            } else {
                return RewardViewData(
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
}

