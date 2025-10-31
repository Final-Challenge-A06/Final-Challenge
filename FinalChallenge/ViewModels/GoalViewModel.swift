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
    @Published var isStep1Valid: Bool = false
    @Published var isStep2Valid: Bool = false
    
    func validateStep1() {
        isStep1Valid = !goalName.trimmingCharacters(in: .whitespaces).isEmpty && _priceText > 0 && selectedImage != nil
    }
    
    func validateStep2() {
        isStep2Valid = !selectedDays.isEmpty && _amountText > 0
    }
    
    // MARK: - Save Logic
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
        try? context.save()
        do {
            try context.save()
            print("Berhasil simpan goal:", goal.name)
        } catch {
            print("Gagal simpan:", error.localizedDescription)
        }
    }
}
