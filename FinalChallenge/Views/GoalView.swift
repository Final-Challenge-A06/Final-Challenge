import SwiftUI

struct GoalView: View {
    
    @State private var showGoalModal = false
    @State private var activeStep = 1
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                Spacer()
                Spacer()
                
                SetGoalView {
                    activeStep = 1
                    showGoalModal = true
                }
                CircleStepView()
                
                Spacer()
                
                BottomItemSelectionView()
            }
            
            MaskotView()
            
            if showGoalModal {
                CenteredModal(isPresented: $showGoalModal) {
                    if activeStep == 1 {
                        GoalModalStep1View(
                            onNext: { activeStep = 2 },
                            onClose: { showGoalModal = false }
                        )
                    } else {
                        GoalModalStep2View(
                            onDone: { showGoalModal = false },
                            onBack: { activeStep = 1 }
                        )
                    }
                }
                .zIndex(1)
            }
        }
    }
}

#Preview {
    GoalView()
}
