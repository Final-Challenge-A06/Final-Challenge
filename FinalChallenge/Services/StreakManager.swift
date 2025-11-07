//
//  StreakManager.swift
//  FinalChallenge
//
//  Created by Euginia Gabrielle on 02/11/25.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    
    private let calendar: Calendar
    private let context: ModelContext
    
    init(context: ModelContext, calendar: Calendar = .current) {
        self.context = context
        self.calendar = calendar
        loadStreak()
    }
    
    // Load streak dari SwiftData
    private func loadStreak() {
        let entity = fetchStreakEntity()
        currentStreak = entity.currentStreak
    }
    
    // Fetch atau buat StreakEntity baru
    private func fetchStreakEntity() -> StreakEntity {
        let descriptor = FetchDescriptor<StreakEntity>(
            predicate: #Predicate { $0.id == "streak_main" }
        )
        
        do {
            if let existing = try context.fetch(descriptor).first {
                return existing
            }
        } catch {
            print("❌ Fetch streak failed:", error.localizedDescription)
        }
        
        // Buat entity baru jika belum ada
        let newEntity = StreakEntity()
        context.insert(newEntity)
        try? context.save()
        return newEntity
    }
    
    // Simpan streak ke SwiftData
    private func saveStreak(_ entity: StreakEntity) {
        do {
            try context.save()
            currentStreak = entity.currentStreak
        } catch {
            print("❌ Save streak failed:", error.localizedDescription)
        }
    }
    
    // Dipanggil setiap kali device ngirim trigger nabung
    func recordSaving(for selectedDays: [String]) {
        print("STREAK SEKARANG - RS", currentStreak)
        
        let entity = fetchStreakEntity()
        let today = calendar.startOfDay(for: Date())
        let todayName = weekdayString(from: today)
        
        // kalau hari ini sudah nabung, keluar dari function
        if let last = entity.lastSaveDate, calendar.isDateInToday(last) { return }
        
        var newStreak: Int
        if let last = entity.lastSaveDate,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(last, inSameDayAs: yesterday) {
            newStreak = entity.currentStreak + 1
        } else {
            newStreak = 1
        }
        
        entity.currentStreak = newStreak
        entity.lastSaveDate = today
        entity.lastCheckDate = today
        
        saveStreak(entity)
        print("Nabung: (\(todayName)) -> streak \(newStreak)")
        print("STREAK SETELAH JALAN - RS", currentStreak)
    }
    
    // Buat cek apakah miss nabung saat today sesuai dengan schedule nabung
    func evaluateMissedDay(for scheduledDays: [String]) {
        print("STREAK SEKARANG - EMD", currentStreak)
        
        let entity = fetchStreakEntity()
        let today = calendar.startOfDay(for: Date())
        let todayName = weekdayString(from: today)
        
        guard let lastCheck = entity.lastCheckDate else {
            entity.lastCheckDate = today
            saveStreak(entity)
            return
        }
        
        if calendar.isDateInToday(lastCheck) { return }
        
        // hari ini jadwal nabung tapi belum nabung
        if scheduledDays.contains(todayName),
           let lastSave = entity.lastSaveDate,
           !calendar.isDateInToday(lastSave) {
            print("Hari \(todayName) jadwal nabung tapi belum nabung")
            entity.currentStreak = 0
        }
        
        entity.lastCheckDate = today
        saveStreak(entity)
        
        print("STREAK SETELAH JALAN - EMD", currentStreak)
    }
    
    func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
