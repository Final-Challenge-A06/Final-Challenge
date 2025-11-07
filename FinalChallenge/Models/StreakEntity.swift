//
//  StreakEntity.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 05/11/25.
//

import SwiftData
import Foundation

@Model
final class StreakEntity {
    @Attribute(.unique) var id: String
    var currentStreak: Int
    var lastSaveDate: Date?
    var lastCheckDate: Date?
    
    init(
        id: String = "streak_main",
        currentStreak: Int = 0,
        lastSaveDate: Date? = nil,
        lastCheckDate: Date? = nil
    ) {
        self.id = id
        self.currentStreak = currentStreak
        self.lastSaveDate = lastSaveDate
        self.lastCheckDate = lastCheckDate
    }
}
