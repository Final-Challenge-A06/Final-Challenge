//
//  SavingProgressEntity.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 05/11/25.
//

import SwiftData
import Foundation

@Model
final class SavingProgressEntity {
    @Attribute(.unique) var id: String
    var goalID: String
    var totalSaving: Int
    var passedSteps: Int
    var lastBalance: Int64
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        goalID: String,
        totalSaving: Int = 0,
        passedSteps: Int = 0,
        lastBalance: Int64 = 0,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.goalID = goalID
        self.totalSaving = totalSaving
        self.passedSteps = passedSteps
        self.lastBalance = lastBalance
        self.updatedAt = updatedAt
    }
}
