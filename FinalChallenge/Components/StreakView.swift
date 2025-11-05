//
//  StreakView.swift
//  FinalChallenge
//
//  Created by Euginia Gabrielle on 05/11/25.
//

import SwiftUI

struct StreakView: View {
    @ObservedObject var streakManager: StreakManager
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
                .font(.title2)
                .symbolEffect(.bounce, value: streakManager.currentStreak)
            
            Text("\(streakManager.currentStreak)-day streak")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.sRGB, red: 0.18, green: 0.35, blue: 0.45))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}
