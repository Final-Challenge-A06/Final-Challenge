//
//  StepDisplayModel.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 30/10/25.
//

import Foundation
import SwiftUI

struct StepDisplayModel: Identifiable {
    let id: Int
    let size: CGFloat
    let xOffset: CGFloat
    let imageName: String
    let rotation: Double
    let isUnlocked: Bool
    let isCheckpoint: Bool
    let isGoal: Bool
}

