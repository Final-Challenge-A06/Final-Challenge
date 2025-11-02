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
    /// Menghasilkan daftar reward berdasarkan totalSteps:
    /// - Checkpoint di step 1 (jika totalStepsClamped >= 1)
    /// - Checkpoint tiap kelipatan 7 (kecuali step terakhir/goal)
    /// - Goal di step terakhir
    /// Selalu minimal ada 1 reward (goal) dengan step = max(totalSteps, 1).
    static func rewards(forTotalSteps totalSteps: Int) -> [RewardMeta] {
        let totalStepsClamped = max(totalSteps, 1)

        var metas: [RewardMeta] = []

        func imageName(for index: Int, isGoal: Bool) -> String {
            if isGoal { return "reward3" }
            switch index % 3 {
            case 0: return "glasses"
            case 1: return "reward2"
            default: return "reward3"
            }
        }

        // 1) Checkpoint step 1 jika ada lebih dari 1 step
        if totalStepsClamped >= 1 {
            metas.append(
                RewardMeta(
                    id: "reward.step.1",
                    step: 1,
                    title: "Checkpoint 1",
                    imageName: imageName(for: 0, isGoal: false)
                )
            )
        }

        // 2) Checkpoint tiap kelipatan 7 yang kurang dari goal
        if totalStepsClamped >= 7 {
            var idx = 1
            var step = 7
            while step < totalStepsClamped {
                metas.append(
                    RewardMeta(
                        id: "reward.step.\(step)",
                        step: step,
                        title: "Checkpoint \(step)",
                        imageName: imageName(for: idx, isGoal: false)
                    )
                )
                idx += 1
                step += 7
            }
        }

        // 3) Goal di step terakhir
        metas.append(
            RewardMeta(
                id: "reward.step.goal",
                step: totalStepsClamped,
                title: "Goal Reward",
                imageName: imageName(for: metas.count, isGoal: true)
            )
        )

        // Jika totalStepsClamped == 1, di atas kita menambahkan step 1 (checkpoint)
        // dan goal di step 1: itu berarti ada 2 entry dengan step sama. Umumnya
        // kita ingin hanya goal untuk kasus 1 step. Deduplicate agar hanya goal:
        if totalStepsClamped == 1 {
            return metas.filter { $0.id == "reward.step.goal" }
        }

        return metas
    }
}
