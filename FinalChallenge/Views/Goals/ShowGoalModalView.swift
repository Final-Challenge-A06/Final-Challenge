//
//  ShowGoalModalView.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 14/11/25.
//

import SwiftUI

struct ShowGoalModalView: View {
    
    @ObservedObject var goalVm: GoalViewModel
    @ObservedObject var bottomItemsVM: BottomItemSelectionViewModel
    @Environment(\.modelContext) private var context
    
    var body: some View {
        CenteredModal(isPresented: $goalVm.showGoalModal) {
            if goalVm.activeStep == 1 {
                GoalModalStep1View(
                    vm: goalVm, bottomItemsVM: bottomItemsVM,
                    onNext: { goalVm.goToNextStep() }
                )
            } else {
                GoalModalStep2View(
                    vm: goalVm,
                    onDone: {
                        goalVm.loadRewardsForView(context: context)
                        bottomItemsVM.setItems(goalVm.rewardViewItems)
                        goalVm.closeModal()
                    },
                    onBack: { goalVm.activeStep = 1 }
                )
            }
        }
        .zIndex(2)
    }
}

#Preview {
    ShowGoalModalView(goalVm: GoalViewModel(), bottomItemsVM: BottomItemSelectionViewModel())
}
