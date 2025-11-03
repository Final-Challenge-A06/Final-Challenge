import Foundation

struct RewardMeta: Identifiable, Equatable {
    let id: String
    let step: Int
    let title: String
    let imageName: String
}

enum RewardCatalog {
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
        
        metas.append(
            RewardMeta(
                id: "reward.step.goal",
                step: totalStepsClamped,
                title: "Goal Reward",
                imageName: imageName(for: metas.count, isGoal: true)
            )
        )
        
        if totalStepsClamped == 1 {
            return metas.filter { $0.id == "reward.step.goal" }
        }

        return metas
    }
}
