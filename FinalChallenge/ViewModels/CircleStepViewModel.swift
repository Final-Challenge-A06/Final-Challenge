//
//  CircleStepViewModel.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 30/10/25.
//

import Foundation
import SwiftUI
import Combine

class CircleStepViewModel: ObservableObject {
    @Published private(set) var steps: [StepDisplayModel] = []
    
    // Input
    private var totalSteps: Int
    private var passedSteps: Int

    // Konstanta (dipindahkan dari View)
    private let sizeNormal: CGFloat = 172
    private let sizeCheckpoint: CGFloat = 246
    private let sizeGoal: CGFloat = 246
    private let zigzagNormal: CGFloat = 80
    private let tiltAngle: Double = 10

    // Properti komputasi untuk lebar (dipindahkan dari View)
    var requiredWidth: CGFloat {
        let zigzagWidth = (sizeNormal / 2 + zigzagNormal) * 2
        return max(sizeCheckpoint, zigzagWidth, sizeGoal)
    }

    init(totalSteps: Int, passedSteps: Int) {
        self.totalSteps = totalSteps
        self.passedSteps = passedSteps
        calculateSteps()
    }

    // Public updater supaya View bisa menyinkronkan perubahan input
    func update(totalSteps: Int, passedSteps: Int) {
        // Hindari kerja ulang jika tidak berubah
        guard self.totalSteps != totalSteps || self.passedSteps != passedSteps else { return }
        self.totalSteps = totalSteps
        self.passedSteps = passedSteps
        calculateSteps()
    }

    // Ini adalah LOGIC UTAMA yang kita pindahkan dari View
    private func calculateSteps() {
        // Lindungi dari range invalid: jika totalSteps <= 0, kosongkan steps
        guard totalSteps > 0 else {
            self.steps = []
            return
        }

        // Clamp passedSteps agar tidak negatif dan tidak melebihi totalSteps
        let safePassed = max(0, min(passedSteps, totalSteps))

        var calculatedSteps: [StepDisplayModel] = []
        
        for step in (1...totalSteps).reversed() {
            // Tipe
            let isGoal = (step == totalSteps)
            let isCheckpoint = (step == 1 || (step % 7 == 0 && !isGoal))
            let isLarge = isCheckpoint || isGoal

            // Ukuran
            let size = isLarge ? sizeCheckpoint : sizeNormal

            // Posisi zigzag
            let isLeft = (step % 2 == 0)
            let xOffset = isLarge ? 0 : (isLeft ? -zigzagNormal : zigzagNormal)

            // Status progress
            let isUnlocked = (step <= safePassed)

            // Gambar (merah/biru)
            let imageName = isUnlocked ? "ss_after" : "ss_before"

            // Rotasi
            let rotation: Double = isLarge ? -10 : (isLeft ? tiltAngle : -tiltAngle - 10)

            // Buat model dan tambahkan ke array
            let stepModel = StepDisplayModel(
                id: step,
                size: size,
                xOffset: xOffset,
                imageName: imageName,
                rotation: rotation,
                isUnlocked: isUnlocked,
                isCheckpoint: isCheckpoint,
                isGoal: isGoal
            )
            calculatedSteps.append(stepModel)
        }
        
        self.steps = calculatedSteps
    }
}

