//
//  ContentView.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 22/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var bleVM: BLEViewModel
    @Environment(\.modelContext) private var context
    @AppStorage("hasCompletedTrial") var hasCompletedTrial = false
    
    var body: some View {
        Group {
            if !bleVM.hasPairedOnce {
                BLETestView()
            }
            else if !hasCompletedTrial {
                TrialDeviceIntroView()
            }
            else {
                GoalView()
                    .environmentObject(bleVM)
            }
        }
        .onAppear {
            bleVM.setContext(context)
            if bleVM.hasPairedOnce {
                bleVM.tryReconnectOnLaunch()
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(BLEViewModel())
}
