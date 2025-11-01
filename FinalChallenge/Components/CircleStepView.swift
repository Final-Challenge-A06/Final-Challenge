import SwiftUI

struct CircleStepView: View {
    @StateObject private var viewModel: CircleStepViewModel

    // Callback untuk parent saat circle ditekan (hanya dipanggil jika unlocked)
    var onTap: (StepDisplayModel) -> Void = { _ in }

    init(totalSteps: Int, passedSteps: Int, onTap: @escaping (StepDisplayModel) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: CircleStepViewModel(
            totalSteps: totalSteps,
            passedSteps: passedSteps
        ))
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.steps) { step in
                // Button agar dapat fokus/tap effect; disabled bila terkunci
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

                        // Overlay lock untuk checkpoint/goal yang belum terbuka
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

