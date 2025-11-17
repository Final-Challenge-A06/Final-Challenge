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

        // 1) Reward untuk step awal (start)
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

        // 2) Reward untuk setiap checkpoint kelipatan 7 (sebelum step terakhir)
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

        // 3) Reward untuk goal-end (step terakhir)
        // Tambahkan hanya jika belum ada (misal totalSteps == 1 sudah tercakup di atas)
        if totalSteps > 1 {
            metas.append(
                RewardModel(
                    id: "reward.step.\(totalSteps)",
                    step: totalSteps,
                    title: "Goal Complete",
                    imageName: "glasses" // ganti sesuai aset yang diinginkan
                )
            )
        }

        return metas
    }
}
