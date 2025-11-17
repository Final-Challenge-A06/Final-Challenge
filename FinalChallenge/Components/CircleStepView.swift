import SwiftUI

struct CircleStepView<LeadingContent: View>: View {
    @ObservedObject var viewModel: CircleStepViewModel
    var onTap: (StepDisplayModel) -> Void
    
    @ViewBuilder let leadingContent: () -> LeadingContent
    
    init(
        viewModel: CircleStepViewModel,
        @ViewBuilder leadingContent: @escaping () -> LeadingContent,
        onTap: @escaping (StepDisplayModel) -> Void
    ) {
        self.viewModel = viewModel
        self.leadingContent = leadingContent
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: 0) {
            
            leadingContent()
            
            ForEach(viewModel.steps) { step in
                Button {
                    onTap(step)
                } label: {
                    ZStack {
                        Image(step.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: step.size, height: step.size)
                            .rotationEffect(.degrees(step.rotation))
                            .offset(x: step.xOffset)

                        if (step.isCheckpoint || step.isGoal) && !step.isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
                                .offset(y: -40)
                        }
                    }
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled((step.isCheckpoint || step.isGoal) && !step.isUnlocked)
                .padding(.vertical, -40)
            }
        }
        .frame(width: viewModel.requiredWidth)
    }
}

extension CircleStepView where LeadingContent == EmptyView {
    init(
        viewModel: CircleStepViewModel,
        onTap: @escaping (StepDisplayModel) -> Void
    ){
        self.init(viewModel: viewModel, leadingContent: { EmptyView() }, onTap: onTap)
    }
}

#Preview {
    ZStack {
        Color(.sRGB, red: 0.08, green: 0.32, blue: 0.40).ignoresSafeArea()
        ScrollView {
            CircleStepView(
                viewModel: CircleStepViewModel(goalSteps: [5], passedSteps: 2)
            ) { step in
                print("Tapped step:", step.id)
            }
            .padding(.vertical, 40)
        }
    }
}
