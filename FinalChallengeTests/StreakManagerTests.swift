//
//  BLEViewModelTests.swift
//  FinalChallenge
//
//  Created by Euginia Gabrielle on 03/11/25.
//

import Testing
import Foundation
@testable import FinalChallenge

final class MockUserDefaults: UserDefaults {
    private var store: [String: Any] = [:]
    
    override func set(_ value: Any?, forKey defaultName: String) {
        store[defaultName] = value
    }
    
    override func object(forKey defaultName: String) -> Any? {
        return store[defaultName]
    }
    
    override func integer(forKey defaultName: String) -> Int {
        return store[defaultName] as? Int ?? 0
    }
}

// MARK: Test Target
@Suite("All Case - Streak Manager Test")
struct StreakManagerTests {
    
    @MainActor
    @Test("recordSaving should start a new streak")
    func testRecordSavingStartNewStreak() async throws {
        let mockDefaults = MockUserDefaults()
        let manager = StreakManager(defaults: mockDefaults)
        
        manager.recordSaving(for: ["Mon", "Tue"])
        
        #expect(manager.currentStreak == 1)
    }
    
    @MainActor
    @Test("recordSaving should continue streak if previous day saved")
    func testRecordSavingContinueStreak() async throws {
        let mockDefaults = MockUserDefaults()
        let manager = StreakManager(defaults: mockDefaults)
        
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        mockDefaults.set(yesterday, forKey: "last_save_date")
        mockDefaults.set(1, forKey: "current_streak")
        
        manager.recordSaving(for: ["Mon", "Tue"])
        
        #expect(manager.currentStreak == 2)
    }
    
    @MainActor
    @Test("evaluateMissedDay resets streak if skipped on scheduled day")
    func testEvaluateMissedDay() async throws {
        let mockDefaults = MockUserDefaults()
        let manager = StreakManager(defaults: mockDefaults)
        
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())!
        
        mockDefaults.set(twoDaysAgo, forKey: "last_check_date")
        mockDefaults.set(twoDaysAgo, forKey: "last_save_date")
        mockDefaults.set(3, forKey: "current_streak")
        
        manager.evaluateMissedDay(for: [manager.weekdayString(from: Date())])
        
        #expect(manager.currentStreak == 0)
    }
    
    @MainActor
    @Test("Don't reset streak when it is not the saving schedule")
    func testEvaluateNonScheduledDayNoReset() async throws {
        let mockDefaults = MockUserDefaults()
        let manager = StreakManager(defaults: mockDefaults)
        
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())
        
        mockDefaults.set(3, forKey: "current_streak")
        mockDefaults.set(yesterday, forKey: "last_save_date")
        mockDefaults.set(yesterday, forKey: "last_check_date")
        
        let scheduledDays: [String] = []
        
        manager.evaluateMissedDay(for: scheduledDays)
        
        #expect(manager.currentStreak == 3)
    }
    
    @MainActor
    @Test("RecordSaving only adds to the streak once a day even if called multiple times")
    func testRecordSavingOncePerDay() async throws {
        let mockDefaults = MockUserDefaults()
        let manager = StreakManager(defaults: mockDefaults)
        let selectedDays = ["Mon", "Wed", "Fri"]
        
        manager.recordSaving(for: selectedDays)
        let first = mockDefaults.integer(forKey: "current_streak")
        
        manager.recordSaving(for: selectedDays)
        let second = mockDefaults.integer(forKey: "current_streak")
        
        #expect(first == second, "Streak tidak boleh bertambah dua kali di hari yang sama")
        #expect(first == 1, "Streak pertama kali harus mulai dari 1")
    }
}
