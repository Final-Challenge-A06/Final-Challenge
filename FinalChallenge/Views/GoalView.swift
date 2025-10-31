import SwiftUI

struct GoalView: View {
    
    @StateObject private var vm = GoalViewModel()
    @Environment(\.modelContext) private var context
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
                
                ScrollView(.vertical, showsIndicators: false) {
                    CircleStepView(
                                totalSteps: 7,
                                passedSteps: 2
                            )
                }
                
                Spacer()
                
                BottomItemSelectionView()
            }
            
            if showGoalModal {
                CenteredModal(isPresented: $showGoalModal) {
                    if activeStep == 1 {
                        GoalModalStep1View(
                            vm: vm,
                            onNext: { activeStep = 2 },
                            onClose: { showGoalModal = false }
                        )
                    } else {
                        GoalModalStep2View(
                            vm: vm,
                            onDone: { vm.saveGoal(context: context); showGoalModal = false },
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


//simpan inputan di swiftdata
//stlh disimpan dikalkulasi untuk jadi ss
