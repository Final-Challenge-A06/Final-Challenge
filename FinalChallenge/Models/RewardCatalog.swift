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

        // 2) Checkpoint kelipatan 7 (tidak termasuk step terakhir/goal)
        let checkpointBaseNames = ["mataBulatPink", "mataNgedipBiru", "mataWinkBiru", "mataNgedipPink", "mataWinkPink"]
        var imageIndex = 0

        for step in stride(from: 7, to: totalSteps, by: 7) {
            // Skip jika checkpoint jatuh di step terakhir (goal)
            guard step < totalSteps else { continue }
            
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

        // Goal selesai (step terakhir) TIDAK mendapatkan reward

        return metas
    }
}
