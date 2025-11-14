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
    
    @StateObject private var flowVM = AppFlowViewModel()
    
    var body: some View {
        Group {
            switch flowVM.currentScreen {
            case .bleSetup:
                BLETestView()
                    .environmentObject(bleVM)
                    .environmentObject(flowVM)
                
            case .startOnboarding:
                StartOnboardingView(bottomItemsVM: BottomItemSelectionViewModel())
                    .environmentObject(flowVM)
                
            case .onboarding:
                OnboardingView(
                    onboardingVM: OnboardingViewModel(),
                    bottomItemsVM: BottomItemSelectionViewModel()
                )
                .environmentObject(flowVM)
                
            case .goalSetupStep1:
                GoalModalStep1View(
                    vm: flowVM.firstGoalVM,
                    bottomItemsVM: flowVM.firstBottomItemsVM,
                    onNext: {
                        flowVM.finishedGoalStep1()
                    }
                )
                
            case .goalSetupStep2:
                GoalModalStep2View(
                    vm: flowVM.firstGoalVM,
                    onDone: {
//                        flowVM.firstGoalVM.saveGoal(context: context)
                        flowVM.finishedGoalStep2()
                    },
                    onBack: {
                        flowVM.startGoalSetupStep1()
                    }
                )
                
            case .goal:
                GoalView()
                    .environmentObject(bleVM)
                    .environmentObject(flowVM)
            }
        }
        .onAppear {
            bleVM.setContext(context)
            flowVM.configureInitialScreen()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BLEViewModel())
}
