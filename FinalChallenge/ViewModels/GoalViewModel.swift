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
    func insert(_ goal: GoalModel) {
        self.insert(goal)
    }
}

@MainActor
final class GoalViewModel: ObservableObject {
    // MARK: - Step 1 Fields
    private var _goalName: String = ""
    private var _priceText: Int = 0
    var selectedItem: PhotosPickerItem? = nil
    var selectedImage: UIImage? = nil
    
    // MARK: - Step 2 Fields
    var selectedDays: Set<String> = []
    private var _amountText: Int = 0
    
    // MARK: - Public computed accessors (Getter + Setter)
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
    var isStep1Valid: Bool = false
    var isStep2Valid: Bool = false
    
    func validateStep1() {
        isStep1Valid = !goalName.trimmingCharacters(in: .whitespaces).isEmpty && _priceText > 0 && selectedImage != nil
    }
    
    func validateStep2() {
        isStep2Valid = !selectedDays.isEmpty && _amountText > 0
    }
    
    // MARK: - Save Logic
    func saveGoal(context: GoalSaving) {
        guard !goalName.isEmpty,
              let price = Int(priceText),
              let amount = Int(amountText),
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
        try? context.save()
        do {
            try context.save()
            print("✅ Berhasil simpan goal:", goal.name)
        } catch {
            print("❌ Gagal simpan:", error.localizedDescription)
        }
    }
}
