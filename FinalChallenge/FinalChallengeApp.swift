//
//  FinalChallengeApp.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 22/10/25.
//

import SwiftUI
import SwiftData

@main
struct FinalChallengeApp: App {
    @StateObject private var bleVM = BLEViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleVM)
        }
        .modelContainer(for: [
            GoalModel.self,
            RewardEntity.self,
            SavingProgressEntity.self,
            StreakEntity.self
        ])
    }
}
