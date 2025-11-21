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

        // 1) Reward pertama (step 1)
        metas.append(
            RewardModel(
                id: "reward.step.1",
                step: 1,
                title: "Bright Blue Eyes",
                imageName: "mataBulatBiru"
            )
        )

        guard totalSteps > 1 else {
            return metas
        }

        // 2) Checkpoint kelipatan 7
        let checkpointBaseNames = ["mataBulatPink", "mataNgedipBiru", "mataWinkBiru", "mataNgedipPink", "mataWinkPink"]
        var imageIndex = 0

        for step in stride(from: 7, to: totalSteps, by: 7) {
            let baseName = checkpointBaseNames[imageIndex % checkpointBaseNames.count]
            imageIndex += 1

            metas.append(
                RewardModel(
                    id: "reward.step.\(step)",
                    step: step,
                    title: "Checkpoint \(step)",
                    imageName: baseName
                )
            )
        }

        // 3) Reward goal selesai (step terakhir)
        metas.append(
            RewardModel(
                id: "reward.step.\(totalSteps)",
                step: totalSteps,
                title: "Goal Complete",
                imageName: "mataNgedipBiru"
            )
        )

        return metas
    }
}
