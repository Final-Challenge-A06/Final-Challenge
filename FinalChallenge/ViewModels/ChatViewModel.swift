//
//  ChatViewModel.swift
//  FinalChallenge
//
//  Created by Assistant on 14/11/25.
//

import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var chat: ChatModel
    
    // Dependency: pastikan kedua VM ini juga @MainActor (di project Anda sudah)
    private let goalVM: GoalViewModel
    private let bleVM: BLEViewModel
    
    // Flag event sekali-tampil
    @Published private var justClaimedFirstReward: Bool = false
    @Published private var justClaimedCheckpoint: Bool = false
    
    // Formatter Rupiah
    private lazy var rupiahFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "IDR"
        nf.currencySymbol = "Rp "
        nf.maximumFractionDigits = 0
        nf.locale = Locale(identifier: "id_ID")
        return nf
    }()
    
    // Hapus default parameter ChatModel() agar tidak memicu actor-isolation error.
    init(chat: ChatModel, goalVM: GoalViewModel, bleVM: BLEViewModel) {
        self.chat = chat
        self.goalVM = goalVM
        self.bleVM = bleVM
    }
    
    // Tandai event klaim dari luar (panggil setelah confirmClaim sukses)
    func markJustClaimedFirstReward() {
        justClaimedFirstReward = true
    }
    
    func markJustClaimedCheckpoint() {
        justClaimedCheckpoint = true
    }
    
    // Evaluasi dan pilih pesan prioritas tertinggi berdasarkan aturan
    func updateMessage(goals: [GoalModel]) {
        let activeGoal = goals.last
        
        let totalSteps = goalVM.totalSteps
        let passedSteps = goalVM.passedSteps
        let hasGoal = (activeGoal != nil) && totalSteps > 0
        let amountPerSave = activeGoal?.amountPerSave ?? 0
        let hasEverSaved = (bleVM.lastBalance > 0) || (goalVM.totalSaving > 0)
        let oneStepLeft = hasGoal && (totalSteps - passedSteps == 1)
        let goalCompleted = hasGoal && (passedSteps >= totalSteps)
        
        // 1) Event klaim (prioritas tertinggi)
        if justClaimedFirstReward {
            chat.showSingle("Great start! Here’s a reward for your first goal!")
            justClaimedFirstReward = false
            return
        }
        if justClaimedCheckpoint {
            chat.showSingle("Try your new accessory and see how Billo looks now!")
            justClaimedCheckpoint = false
            return
        }
        
        // 2) Goal complete (belum ambil uang)
        if goalCompleted && !goalVM.currentGoalIsClaimed {
            chat.showSingle("Goal complete! Billo’s letting you take your savings")
            return
        }
        
        // 3) Kurang 1 step lagi
        if oneStepLeft {
            chat.showSingle("A little more to reach your goal")
            return
        }
        
        // 4) Selesai set goal dan belum pernah menabung
        if hasGoal && !hasEverSaved && amountPerSave > 0 {
            let formatted = rupiahFormatter.string(from: NSNumber(value: amountPerSave)) ?? "Rp \(amountPerSave)"
            chat.showSingle("Let’s try saving \(formatted) for the first time!")
            return
        }
        
        // 5) Goal sudah tercapai dan mendorong buat goal baru (setelah ambil uang)
        if goalCompleted && goalVM.currentGoalIsClaimed {
            chat.showSingle("Now that its finish, keep our saving habit continue, do more goals and complete it")
            return
        }
        
        // Fallback default
        chat.showSingle("Keep going!")
    }
}

