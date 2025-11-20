//
//  OnboardingModel.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 11/11/25.
//

import Foundation
import CoreGraphics

struct OnboardingModel: Identifiable, Equatable {
    let id: UUID = UUID()
    let title: String
    let imageName: String
    let description: String
    let offsetX: CGFloat
    let offsetY: CGFloat
    let rotationDegrees: Double

    init(
        title: String,
        imageName: String,
        description: String,
        offsetX: CGFloat = -400,
        offsetY: CGFloat = -240,
        rotationDegrees: Double = 20
    ) {
        self.title = title
        self.imageName = imageName
        self.description = description
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.rotationDegrees = rotationDegrees
    }
}

extension OnboardingModel {
    static let defaultPages: [OnboardingModel] = [
        OnboardingModel(
            title: "Set Your First Goal!",
            imageName: "onboarding_1",
            description: "Hey there!, let’s make your first goal! Finish it and Billo will pop open!",
            offsetX: -400, offsetY: -240, rotationDegrees: 20
        ),
        
        OnboardingModel(
            title: "Add Your Savings",
            imageName: "onboarding_2",
            description: "Put your money into Billo just like shown in the picture, and watch your progress go up!",
            offsetX: 380, offsetY: -240, rotationDegrees: -20
        ),
        
        OnboardingModel(
            title: "Keep Your Streak Going!",
            imageName: "onboarding_3",
            description: "Your streak adds up each time you save. Just don’t miss the days you set, or it will start over.",
            offsetX: -350, offsetY: 60, rotationDegrees: -20
        ),
        
        OnboardingModel(
            title: "Reach Checkpoint",
            imageName: "onboarding_4",
            description: "Every time you save, you move closer to your next checkpoint. Reach it to unlock a new accessory for Billo!",
            offsetX: 320, offsetY: 80, rotationDegrees: 10
        ),
        
        OnboardingModel(
            title: "Goal Complete!",
            imageName: "robot",
            description: "You’ve finished your goal and Billo’s ready to open! Take your savings and start a new goal to keep going.",
            offsetX: -350, offsetY: 60, rotationDegrees: -20
        ),
        
        OnboardingModel(
            title: "Ready to Start Saving?",
            imageName: "robot",
            description: "",
            offsetX: -300, offsetY: -150, rotationDegrees: -20
        )
    ]
}

