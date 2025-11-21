//
//  GoalModel.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftData
import Foundation

@Model
final class GoalModel {
    @Attribute(.unique) var id: String
    var createdAt: Date // untuk sorting
    
    var name: String
    var targetPrice: Int
    var imageData: Data?
    var savingDays: [String]
    var amountPerSave: Int
    var totalSaving: Int
    var passedSteps: Int
    var totalSteps: Int {
        amountPerSave > 0 ? targetPrice / amountPerSave : 0
    }

    init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        name: String,
        targetPrice: Int,
        imageData: Data? = nil,
        savingDays: [String],
        amountPerSave: Int, 
        totalSaving: Int = 0,
        passedSteps: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.targetPrice = targetPrice
        self.imageData = imageData
        self.savingDays = savingDays
        self.amountPerSave = amountPerSave
        self.totalSaving = totalSaving
        self.passedSteps = passedSteps
    }
}
