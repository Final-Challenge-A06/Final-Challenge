//
//  RewardCatalog.swift
//  FinalChallenge
//
//  Created by Assistant on 01/11/25.
//

import Foundation

struct RewardMeta: Identifiable, Equatable {
    let id: String
    let step: Int
    let title: String
    let imageName: String
}

enum RewardCatalog {
    // Default mapping: step 1, 7, goal
    static func rewards(forTotalSteps totalSteps: Int) -> [RewardMeta] {
        [
            RewardMeta(id: "reward.step.1", step: 1, title: "Glasses", imageName: "glasses"),
            RewardMeta(id: "reward.step.7", step: 7, title: "Reward 2", imageName: "reward2"),
            RewardMeta(id: "reward.step.goal", step: totalSteps, title: "Reward 3", imageName: "reward3")
        ]
    }
}

