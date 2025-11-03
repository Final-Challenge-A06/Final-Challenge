import Foundation
import SwiftUI
import Combine

final class CircleStepViewModel: ObservableObject {
    @Published private(set) var steps: [StepDisplayModel] = []
    
    private var totalSteps: Int
    private var passedSteps: Int
    private let sizeNormal: CGFloat = 172
    private let sizeCheckpoint: CGFloat = 246
    private let sizeGoal: CGFloat = 246
    private let zigzagNormal: CGFloat = 80
    private let tiltAngle: Double = 10

    var requiredWidth: CGFloat {
        let zigzagWidth = (sizeNormal / 2 + zigzagNormal) * 2
        return max(sizeCheckpoint, zigzagWidth, sizeGoal)
    }

    init(totalSteps: Int, passedSteps: Int) {
        self.totalSteps = totalSteps
        self.passedSteps = passedSteps
        calculateSteps()
    }

    func update(totalSteps: Int, passedSteps: Int) {
        guard self.totalSteps != totalSteps || self.passedSteps != passedSteps else { return }
        self.totalSteps = totalSteps
        self.passedSteps = passedSteps
        calculateSteps()
    }

    private func calculateSteps() {
        guard totalSteps > 0 else { steps = []; return }

        let safePassed = max(0, min(passedSteps, totalSteps))
        var result: [StepDisplayModel] = []

        for step in (1...totalSteps).reversed() {
            let isGoal = (step == totalSteps)
            let isCheckpoint = (step == 1 || (step % 7 == 0 && !isGoal))
            let isLarge = isCheckpoint || isGoal

            let size = isLarge ? sizeCheckpoint : sizeNormal
            let isLeft = (step % 2 == 0)
            let xOffset = isLarge ? 0 : (isLeft ? -zigzagNormal : zigzagNormal)

            let isUnlocked = (step <= safePassed)
            let imageName = isUnlocked ? "ss_after" : "ss_before"
            let rotation: Double = isLarge ? -10 : (isLeft ?  tiltAngle : -tiltAngle - 10)

            result.append(
                StepDisplayModel(
                    id: step,
                    size: size,
                    xOffset: xOffset,
                    imageName: imageName,
                    rotation: rotation,
                    isUnlocked: isUnlocked,
                    isCheckpoint: isCheckpoint,
                    isGoal: isGoal
                )
            )
        }
        steps = result
    }
}
