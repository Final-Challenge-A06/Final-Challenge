//
//  StreakView.swift
//  FinalChallenge
//
//  Created by Euginia Gabrielle on 05/11/25.
//

import SwiftUI
import SwiftData

struct StreakView: View {
    @ObservedObject var streakManager: StreakManager
    
    var body: some View {
        ZStack{
            Image("background_streak")
            
            VStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .resizable()
                    .frame(width: 40, height: 52)
                    .foregroundColor(.orange)
                    .symbolEffect(.bounce, value: streakManager.currentStreak)
                
                Text("\(streakManager.currentStreak)")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: GoalModel.self, RewardEntity.self, SavingProgressEntity.self, StreakEntity.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )
    let manager = StreakManager(context: container.mainContext)
    manager.currentStreak = 5
    return StreakView(streakManager: manager)
        .padding()
        .modelContainer(container)
}
