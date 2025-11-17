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
    @Published var currentGoalIsClaimed: Bool = false
    
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
        isStep1Valid = !goalName.trimmingCharacters(in: .whitespaces).isEmpty && _priceText >= 50_000
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
//            latestGoal = goal
//            totalSteps = goal.totalSteps
            
            let progressEntity = SavingProgressEntity(
                goalID: goal.id,
                totalSaving: 0,
                passedSteps: 0
            )
            context.insert(progressEntity)
            try context.save()
            
            self.currentGoalIsClaimed = false
            
//            currentProgress = progressEntity
//            passedSteps = 0
//            totalSaving = 0
            
            // Refresh katalog reward
//            rewardCatalog = RewardCatalog.rewards(forTotalSteps: totalSteps)
        } catch {
            print("❌ Gagal simpan:", error.localizedDescription)
        }
    }
    
    // MARK: - Load Progress dari SwiftData
    func loadProgress(for goal: GoalModel, context: ModelContext) {
        let goalID = goal.id
        let descriptor = FetchDescriptor<SavingProgressEntity>(
            predicate: #Predicate { $0.goalID == goalID }
        )
        
        do {
            if let progress = try context.fetch(descriptor).first {
                currentProgress = progress
                totalSaving = progress.totalSaving
                passedSteps = progress.passedSteps
            } else {
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
    private func saveProgress(currentGoalSaving: Int, currentGoalPassedSteps: Int, context: ModelContext) {
        guard let progress = currentProgress else { return }
        
        progress.totalSaving = currentGoalSaving
        progress.passedSteps = currentGoalPassedSteps
        progress.updatedAt = Date()
        
        do {
            try context.save()
            print("✅ Progress saved: totalSaving=\(currentGoalSaving), passedSteps=\(currentGoalPassedSteps)")
        } catch {
            print("❌ Save progress failed:", error.localizedDescription)
        }
    }
    
    // MARK: - Update Goals
    func updateGoals(_ goals: [GoalModel], context: ModelContext) {
        let previousGoalId = latestGoal?.id
        latestGoal = goals.last
        
//        if let goal = latestGoal {
//            totalSteps = goal.totalSteps
//            
//            if previousGoalId != goal.name {
//                loadProgress(for: goal, context: context)
//            }
//        } else {
//            totalSteps = 0
//            passedSteps = 0
//            totalSaving = 0
//            currentProgress = nil
//        }
//        
//        rewardCatalog = RewardCatalog.rewards(forTotalSteps: totalSteps)
        
        // MARK: 1. Handle jika tidak ada goal sama sekali
        if goals.isEmpty {
            totalSteps = 0
            passedSteps = 0
            totalSaving = 0
            currentProgress = nil
            rewardCatalog = []
            return
        }
        
        // MARK: 2. Pisahkan goals
        let currentGoal = goals.last!
        let completedGoals = goals.dropLast()
        
        // MARK: 3. Hitung progres kumulatif
        var cumulativeTotalSteps = 0
        var cumulativePassedSteps = 0
        
        // Tambah semua total steps dari goal yang sudah selesai
        for goal in completedGoals {
            cumulativeTotalSteps += goal.totalSteps
            cumulativePassedSteps += goal.totalSteps // Goal selesai 100% passed
        }
        
        // MARK: 4. Load progress untuk goal saat ini
        // Jika goal aktif berubah, load progress dari SwiftData
        if previousGoalId != currentGoal.id {
            loadProgress(for: currentGoal, context: context)
        }
        
        // MARK: 5. Gabungkan progres goal aktif ke total kumulatif
        cumulativeTotalSteps += currentGoal.totalSteps
        
        // `self.passedSteps` sekarang berisi langkah HANYA untuk goal saat ini (dari loadProgress)
        // Tambahkan itu ke total kumulatif
        cumulativePassedSteps += self.passedSteps
        
        // MARK: 6. Set @Published variables untuk UI
        // Update CircleStepViewModel secara otomatis
        self.totalSteps = cumulativeTotalSteps
        self.passedSteps = cumulativePassedSteps
        
        // MARK: 7. Update reward
        // Katalog reward sekarang harus berdasarkan total steps kumulatif
        self.rewardCatalog = RewardCatalog.rewards(forTotalSteps: cumulativeTotalSteps)
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
    
    func getClaimedSteps(context: ModelContext) -> Set<Int> {
        let entities = fetchAllRewards(context: context)
        var claimedSteps: Set<Int> = []
        
        for meta in rewardCatalog {
            if let entity = entities.first(where: { $0.id == meta.id }), entity.claimed {
                claimedSteps.insert(meta.step)
            }
        }
        
        return claimedSteps
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
    
    // MARK: - Progress update manual (modal) — masih ada, tapi tidak akan dipakai untuk BLE
    func applySaving(amount: Int, context: ModelContext) {
        guard amount > 0 else { return }
        totalSaving += amount
        recalcPassedStepsFromSaving()
        saveProgress(currentGoalSaving: totalSaving, currentGoalPassedSteps: passedSteps, context: context)
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
//        passedSteps = 0
        saveProgress(currentGoalSaving: 0, currentGoalPassedSteps: 0, context: context)
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
    
    // MARK: - NEW: Progress dari BLE balance
    func updateProgressFromBLEBalance(_ balance: Int64, allGoals: [GoalModel], context: ModelContext) {
//        guard let goal = latestGoal, goal.amountPerSave > 0 else {
//            passedSteps = 0
//            totalSaving = Int(balance)
//            saveProgress(context: context)
//            return
//        }
//        // sinkronkan totalSaving dengan saldo device (opsional tapi biasanya diinginkan)
//        totalSaving = Int(balance)
//        let computed = Int(balance) / goal.amountPerSave
//        let clamped = min(computed, totalSteps)
//        if clamped != passedSteps {
//            passedSteps = clamped
//        }
//        saveProgress(context: context)
        
        // 1. Validasi: Pastikan ada goal aktif
        guard let currentGoal = allGoals.last, currentGoal.amountPerSave > 0 else {
            // Tidak ada goal aktif / amountPerSave = 0
            self.totalSaving = Int(balance)
//            if currentProgress != nil {
//                saveProgress(currentGoalSaving: Int(balance), currentGoalPassedSteps: 0, context: context)
//            }
            // `updateGoals` sudah mengatur `passedSteps` kumulatif (dari goal lama)
            // Jadi kita tidak perlu mengaturnya di sini.
            return
        }
        
        // Hitung progres hanya untuk goal saat ini
        var newTotalSavingCurrentGoal = Int(balance)
        var newPassedStepsCurrentGoal = 0
        
        // Cek skenario: Apakah kita baru saja menekan "Take Your Money"?
        if self.currentGoalIsClaimed && balance == 0 {
            // YA. Ini adalah reset setelah goal selesai.
            // Saldo device 0, tapi 'passedSteps' untuk goal ini harus 100% (totalSteps-nya).
            newTotalSavingCurrentGoal = 0
            newPassedStepsCurrentGoal = currentGoal.totalSteps // <-- KUNCI 1: Anggap step-nya penuh
            
        } else if currentGoal.amountPerSave > 0 {
            // TIDAK. Ini adalah update progres normal.
            newTotalSavingCurrentGoal = Int(balance)
            let calculatedSteps = newTotalSavingCurrentGoal / currentGoal.amountPerSave
            // KUNCI 2: Pastikan step tidak melebihi total step goal SAAT INI
            newPassedStepsCurrentGoal = min(calculatedSteps, currentGoal.totalSteps)
            
        } else {
            // Skenario normal, tapi amountPerSave = 0 (tidak bisa hitung progres)
            newTotalSavingCurrentGoal = Int(balance)
            newPassedStepsCurrentGoal = 0
        }
        
        // 2. Simpan progres saat ini ke database (SavingProgressEntity)
        saveProgress(
            currentGoalSaving: newTotalSavingCurrentGoal,
            currentGoalPassedSteps: newPassedStepsCurrentGoal,
            context: context
        )
        
        // Hitung progres kumulatif untuk ui
        let completedGoals = allGoals.dropLast()
        var cumulativeTotalSteps = 0
        var cumulativePassedSteps = 0
        
        // 3. Tambahkan semua goal yang sudah selesai
        for goal in completedGoals {
            cumulativeTotalSteps += goal.totalSteps
            cumulativePassedSteps += goal.totalSteps
        }
        
        // 4. Tambahkan progres goal saat ini
        cumulativeTotalSteps += currentGoal.totalSteps
        cumulativePassedSteps += newPassedStepsCurrentGoal // ambil dari hitungan baru di atas
        
        // 5. Update @Published properties untuk ui (CircleStepView)
        self.totalSteps = cumulativeTotalSteps
        self.passedSteps = cumulativePassedSteps
        self.totalSaving = newTotalSavingCurrentGoal // update total saving di ui
    }
}

