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
    
    init() {
        let fm = FileManager.default
        if let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            try? fm.createDirectory(at: appSupport, withIntermediateDirectories: true)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleVM)
                .preferredColorScheme(.light)
        }
        .modelContainer(for: [
            GoalModel.self,
            RewardEntity.self,
            SavingProgressEntity.self,
            StreakEntity.self,
            BalanceModel.self
        ])
    }
}
