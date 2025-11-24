//
//  AppFlowViewModel.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 13/11/25.
//

import SwiftUI
import Combine

enum AppScreen {
    case bleSetup
    case startOnboarding
    case onboarding
    case goalSetupStep1
    case goalSetupStep2
    case goal
}

final class AppFlowViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .bleSetup
    
    @AppStorage("initialFlowStage") var initialFlowStage: Int = 0
    @AppStorage("hasPairedOnce")    var hasPairedOnce: Bool = false
    
    @Published var firstGoalVM = GoalViewModel()
    @Published var firstBottomItemsVM = BottomItemSelectionViewModel()
    
    func configureInitialScreen() {
        switch initialFlowStage {
        case 0:
            currentScreen = .bleSetup
        case 1:
            currentScreen = .startOnboarding
        case 2:
            currentScreen = .onboarding
        case 3:
            currentScreen = .goalSetupStep1
        case 4:
            currentScreen = .goalSetupStep2
        default:
            currentScreen = .goal
        }
    }
    
    func markPairedOnce() {
        hasPairedOnce = true
        if initialFlowStage < 1 { initialFlowStage = 1 }
    }
    
    func goToStartOnboarding() {
        if initialFlowStage < 1 { initialFlowStage = 1 }
        currentScreen = .startOnboarding
    }
    
    // MARK: - StartOnboarding → Onboarding
    
    func goToOnboarding() {
        if initialFlowStage < 2 { initialFlowStage = 2 }
        currentScreen = .onboarding
    }
    
    // MARK: - Onboarding → Goal step 1
    
    func startGoalSetup() {
        if initialFlowStage < 3 { initialFlowStage = 3 }
        currentScreen = .goalSetupStep1
    }
    
    // MARK: - Dipanggil dari GoalModalStep1View
    func finishedGoalStep1() {
        if initialFlowStage < 4 { initialFlowStage = 4 }
        currentScreen = .goalSetupStep2
    }
    
    // MARK: - Dipanggil dari GoalModalStep2View
    func finishedGoalStep2() {
        if initialFlowStage < 5 { initialFlowStage = 5 }
        currentScreen = .goal
    }
    
    func goToGoal() {
        initialFlowStage = max(initialFlowStage, 5)
        currentScreen = .goal
    }
    
    func startGoalSetupStep1() {
        currentScreen = .goalSetupStep1
    }
}
