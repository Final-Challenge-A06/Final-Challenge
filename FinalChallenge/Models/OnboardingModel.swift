//
//  OnboardingModel.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 11/11/25.
//

import Foundation

struct OnboardingModel: Identifiable, Equatable {
    let id: UUID = UUID()
    let title: String
    let imageName: String
    let description: String
}

extension OnboardingModel {
    static let defaultPages: [OnboardingModel] = [
        OnboardingModel(
            title: "Set Your First Goal!",
            imageName: "robot",
            description: "Hey there!, let’s make your first goal!. Finish it and Billo will pop open!"
        ),
        
        OnboardingModel(
            title: "Add Your Savings",
            imageName: "robot",
            description: "Put your money into Billo just like shown in the picture, and watch your progress go up!"
        ),
        
        OnboardingModel(
            title: "Keep Your Streak Going!",
            imageName: "robot",
            description: "Your streak adds up each time you save. Just don’t miss the days you set, or it will start over."
        ),
        
        OnboardingModel(
            title: "Reach Checkpoint",
            imageName: "robot",
            description: "Every time you save, you move closer to your next checkpoint. Reach it to unlock a new accessory for Billo!"
        ),
        
        OnboardingModel(
            title: "Goal Complete!",
            imageName: "robot",
            description: "You’ve finished your goal and Billo’s ready to open! Take your savings and start a new goal to keep going."
        ),
        
        OnboardingModel(
            title: "Ready to Start Saving?",
            imageName: "robot",
            description: ""
        )
    ]
}
