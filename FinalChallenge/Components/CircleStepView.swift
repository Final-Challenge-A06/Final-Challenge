import SwiftUI

struct CircleStepView: View {
    @StateObject private var viewModel: CircleStepViewModel

    // Callback untuk parent saat circle ditekan (hanya dipanggil jika unlocked)
    var onTap: (StepDisplayModel) -> Void = { _ in }

    private let totalSteps: Int
    private let passedSteps: Int

    init(totalSteps: Int, passedSteps: Int, onTap: @escaping (StepDisplayModel) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: CircleStepViewModel(
            totalSteps: totalSteps,
            passedSteps: passedSteps
        ))
        self.totalSteps = totalSteps
        self.passedSteps = passedSteps
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: 0) {
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
        // Sinkronkan perubahan props dari parent ke VM
        .onChange(of: totalSteps) { newValue in
            viewModel.update(totalSteps: newValue, passedSteps: passedSteps)
        }
        .onChange(of: passedSteps) { newValue in
            viewModel.update(totalSteps: totalSteps, passedSteps: newValue)
        }
    }
}

#Preview {
    ZStack {
        Color(.sRGB, red: 0.08, green: 0.32, blue: 0.40)
            .ignoresSafeArea()
        ScrollView {
            CircleStepView(
                totalSteps: 9,
                passedSteps: 2
            ) { step in
                print("Tapped step:", step.id)
            }
            .padding(.vertical, 40)
        }
    }
}

