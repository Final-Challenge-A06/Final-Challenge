//
//  MockModelContext.swift
//  FinalChallengeTests
//
//  Created by Euginia Gabrielle on 31/10/25.
//

import Foundation
import SwiftData
@testable import FinalChallenge

final class MockModelContext: GoalSaving {
    var didInsert = false
    var didSave = false
    var insertedGoals: [GoalModel] = []
    
    func insert(_ goal: GoalModel) {
        didInsert = true
        insertedGoals.append(goal)
    }
    
    func save() throws {
        didSave = true
    }
}
