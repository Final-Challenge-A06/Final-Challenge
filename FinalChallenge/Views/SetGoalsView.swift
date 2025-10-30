import SwiftUI

struct SetGoalsView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea().ignoresSafeArea(edges: .all)
            
            VStack(spacing: 28) {
                Spacer()
                Spacer()
                Spacer()
                
                GoalView()
                CircleStepView()
                
                Spacer()
                
                BottomItemSelectionView()
            }
            
            MaskotView()
        }
    }
}

#Preview {
    SetGoalsView()
}
