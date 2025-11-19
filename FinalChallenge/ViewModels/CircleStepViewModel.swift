import Foundation
import SwiftUI
import Combine

final class CircleStepViewModel: ObservableObject {
    @Published private(set) var steps: [StepDisplayModel] = []
    
//    private var totalSteps: Int
    private var goalSteps: [Int]
    private var passedSteps: Int
    private var claimedSteps: Set<Int>
    
    // For adjusting stones size and position
    private let sizeNormal: CGFloat = 172
    private let sizeCheckpoint: CGFloat = 246
    private let sizeGoal: CGFloat = 246
    private let zigzagNormal: CGFloat = 80
    private let tiltAngle: Double = 10

    var requiredWidth: CGFloat {
        let zigzagWidth = (sizeNormal / 2 + zigzagNormal) * 2
        return max(sizeCheckpoint, zigzagWidth, sizeGoal)
    }

    // Inisialisasi nilai awal dan langsung hitung model langkah untuk UI.
    init(goalSteps:[Int], passedSteps: Int, claimedSteps: Set<Int> = []) {
//        self.totalSteps = totalSteps
        self.goalSteps = goalSteps
        self.passedSteps = passedSteps
        self.claimedSteps = claimedSteps
        calculateSteps()
    }

    // Update total/passed steps bila berubah lalu hitung ulang model langkah.
    func updateSteps(goalSteps: [Int], passedSteps: Int, claimedSteps: Set<Int> = []) {
//        guard self.totalSteps != totalSteps || self.passedSteps != passedSteps else { return }
        guard self.goalSteps != goalSteps || self.passedSteps != passedSteps || self.claimedSteps != claimedSteps else { return }
//        self.totalSteps = totalSteps
        self.goalSteps = goalSteps
        self.passedSteps = passedSteps
        self.claimedSteps = claimedSteps
        calculateSteps()
    }

    // Hitung daftar StepDisplayModel (ukuran, posisi, status) untuk ditampilkan melingkar.
    private func calculateSteps() {
        // Hitung total kumulatif dari daftar goal
        let totalSteps = goalSteps.reduce(0, +)
        guard totalSteps > 0 else { steps = []; return }
        
        var goalStartSteps: Set<Int> = [1]
        var goalEndSteps: Set<Int> = []
        var intermediateCheckpoints: Set<Int> = []
        
        var cumulative = 0
        for stepsInGoal in goalSteps {
            var relativeStep = 1
            while relativeStep <= stepsInGoal {
                if relativeStep % 7 == 0 {
                    let absoluteStep = cumulative + relativeStep
                    intermediateCheckpoints.insert(absoluteStep)
                }
                relativeStep += 1
            }
            cumulative += stepsInGoal
            goalEndSteps.insert(cumulative)
        }
            
            // Jika bukan goal terakhir, tambah step berikutnya sebagai start
//            if index < goalSteps.count - 1 {
//                goalStartSteps.insert(cumulative + 1)
//            }

        let safePassed = max(0, min(passedSteps, totalSteps))
        var result: [StepDisplayModel] = []

        for step in (1...totalSteps).reversed() {
//            let isGoal = (step == totalSteps)
//            let isCheckpoint = (step == 1 || (step % 7 == 0 && !isGoal))
//            let isLarge = isCheckpoint || isGoal
            
            let isGoal = goalEndSteps.contains(step)
            let isCheckpoint = goalStartSteps.contains(step)
            let isIntermediateCheckpoint = intermediateCheckpoints.contains(step) && !isGoal && !isCheckpoint
            let isLarge = isGoal || isCheckpoint || isIntermediateCheckpoint

            let size = isLarge ? sizeCheckpoint : sizeNormal
            let isLeft = (step % 2 == 0)
            let xOffset = isLarge ? 0 : (isLeft ? -zigzagNormal : zigzagNormal)

            let isUnlocked = (step <= safePassed)
            let imageName = isUnlocked ? "ss_after" : "ss_before"
            let rotation: Double = isLarge ? 0 : (isLeft ?  tiltAngle : -tiltAngle)

            result.append(
                StepDisplayModel(
                    id: step,
                    size: size,
                    xOffset: xOffset,
                    imageName: imageName,
                    rotation: rotation,
                    isUnlocked: isUnlocked,
                    isCheckpoint: isCheckpoint || isIntermediateCheckpoint,
                    isGoal: isGoal,
                    isClaimed: claimedSteps.contains(step)
                )
            )
        }
        steps = result
    }
}

