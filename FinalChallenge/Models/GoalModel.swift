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
    var name: String
    var targetPrice: Int
    var imageData: Data?
    var savingDays: [String]
    var amountPerSave: Int

    init(
            name: String,
            targetPrice: Int,
            imageData: Data? = nil,
            savingDays: [String],
            amountPerSave: Int
        ) {
            self.name = name
            self.targetPrice = targetPrice
            self.imageData = imageData
            self.savingDays = savingDays
            self.amountPerSave = amountPerSave
        }
}
