import Foundation
import SwiftData

struct RewardModel: Identifiable, Equatable {
    let id: String
    let step: Int
    let title: String
    let imageName: String
}

enum RewardCatalog {
    static func rewards(forTotalSteps totalSteps: Int) -> [RewardModel] {
        let totalStepsClamped = max(totalSteps, 1)

        var metas: [RewardModel] = []

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
                RewardModel(
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
                    RewardModel(
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
            RewardModel(
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

struct RewardState: Identifiable, Equatable {
    enum State: Equatable {
        case locked
        case claimable
        case claimed
    }

    let id: String
    let title: String
    let imageName: String
    var state: State
}

@Model
final class RewardEntity {
    @Attribute(.unique) var id: String
    var unlockedAtStep: Int
    var imageName: String
    var title: String
    var claimed: Bool
    var claimedAt: Date?

    init(
        id: String,
        unlockedAtStep: Int,
        imageName: String,
        title: String,
        claimed: Bool = false,
        claimedAt: Date? = nil
    ) {
        self.id = id
        self.unlockedAtStep = unlockedAtStep
        self.imageName = imageName
        self.title = title
        self.claimed = claimed
        self.claimedAt = claimedAt
    }
}
