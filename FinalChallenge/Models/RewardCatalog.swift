//
//  RewardCatalog.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 13/11/25.
//

import Foundation

enum RewardCatalog {
    static func rewards(forTotalSteps totalSteps: Int) -> [RewardModel] {
        guard totalSteps > 0 else { return [] }

        var metas: [RewardModel] = []

        metas.append(
            RewardModel(
                id: "reward.step.1",
                step: 1,
                title: "First Saving Reward",
                imageName: "glasses"
            )
        )

        guard totalSteps > 1 else {
            return metas
        }

        let checkpointImageNames = ["glasses1", "swagglasses", "glasses1"]
        var imageIndex = 0

        for step in stride(from: 7, to: totalSteps, by: 7) {
            let imageName = checkpointImageNames[imageIndex % checkpointImageNames.count]
            imageIndex += 1

            metas.append(
                RewardModel(
                    id: "reward.step.\(step)",
                    step: step,
                    title: "Checkpoint \(step)",
                    imageName: imageName
                )
            )
        }
        return metas
    }
}
