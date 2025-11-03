//
//  StreakManager.swift
//  FinalChallenge
//
//  Created by Euginia Gabrielle on 02/11/25.
//

import Foundation

final class StreakManager {
    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current
    private let streakKey = "current_streak"
    private let lastSaveKey = "last_save_date"
    private let lastCheckKey = "last_check_date"
    
    // Getter
    var currentStreak: Int {
        defaults.integer(forKey: streakKey)
    }
    
    // Dipanggil setiap kali device ngirim trigger nabung
    func recordSaving(for selectedDays: [String]) {
        let today = calendar.startOfDay(for: Date())
        let todayName = weekdayString(from: today)
        let lastDate = defaults.object(forKey: lastSaveKey) as? Date
        
        // kalau hari ini sudah nabung, keluar dari function
        if let last = lastDate, calendar.isDateInToday(last) { return }
        
        var newStreak: Int
        if let last = lastDate,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(last, inSameDayAs: yesterday) {
            newStreak = currentStreak + 1
        } else {
            newStreak = 1
        }
        
        defaults.set(newStreak, forKey: streakKey)
        defaults.set(today, forKey: lastSaveKey)
        defaults.set(today, forKey: lastCheckKey)
        print("Nabung: (\(todayName)) -> streak \(newStreak)")
    }
    
    // Buat cek apakah miss nabung saat today sesuai dengan schedule nabung
    func evaluateMissedDay(for scheduledDays: [String]) {
        let today = calendar.startOfDay(for: Date())
        let todayName = weekdayString(from: today)
        guard let lastCheck = defaults.object(forKey: lastCheckKey) as? Date else {
            defaults.set(today, forKey: lastCheckKey)
            return
        }
        if calendar.isDateInToday(lastCheck) { return }
        
        // hari ini jadwal nabung tapi belum nabung
        if scheduledDays.contains(todayName),
           let lastSave = defaults.object(forKey: lastSaveKey) as? Date,
           !calendar.isDateInToday(lastSave) {
            print("Hari \(todayName) jadwal nabung tapi belum nabung -> streak reset")
            defaults.set(0, forKey: streakKey)
        }
        defaults.set(today, forKey: lastCheckKey)
    }
    
    private func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
