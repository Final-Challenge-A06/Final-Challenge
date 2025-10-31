//
//  GoalView.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 30/10/25.
//

import SwiftUI

struct SetGoalView: View {
    
    var onTap: () -> Void = {}
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.yellow)
                .frame(width: 320, height: 320)
            
            VStack(spacing: 8) {
                Text("Set").font(.largeTitle.bold())
                Text("Goals").font(.largeTitle.bold())
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}

#Preview {
    SetGoalView()
}
