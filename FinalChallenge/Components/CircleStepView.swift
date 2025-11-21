import SwiftUI

struct CircleStepView<LeadingContent: View>: View {
    @ObservedObject var viewModel: CircleStepViewModel
    var onTap: (StepDisplayModel) -> Void
    var goalImage: UIImage?
    
    @ViewBuilder let leadingContent: () -> LeadingContent
    
    init(
        viewModel: CircleStepViewModel,
        goalImage: UIImage? = nil,
        @ViewBuilder leadingContent: @escaping () -> LeadingContent,
        onTap: @escaping (StepDisplayModel) -> Void
    ) {
        self.viewModel = viewModel
        self.goalImage = goalImage
        self.leadingContent = leadingContent
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: 0) {
            
            leadingContent()
            
            ForEach(viewModel.steps) { step in
                ZStack {
                    Button {
                        // Prioritaskan toggle untuk step goal yang sudah selesai (unlocked).
                        if step.isGoal && step.isUnlocked {
                            viewModel.toggleGoalImageVisibility(for: step.id)
                            return
                        }
                        
                        // Jika checkpoint/goal unlocked tapi belum di-claim → buka modal klaim.
                        if (step.isCheckpoint || step.isGoal), step.isUnlocked, !step.isClaimed {
                            onTap(step)
                            return
                        }
                        
                        // Default fallback
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
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
                                    .offset(y: -30)
                            } else if step.isCheckpoint && step.isUnlocked {
                                Image(systemName: "lock.open.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
                                    .offset(y: -30)
                            } else if step.isGoal && step.isUnlocked {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
                                    .offset(y: -30)
                            }
                        }
                        .contentShape(Circle())
                    }
                    .id(step.id)
                    .buttonStyle(.plain)
                    .disabled((step.isCheckpoint || step.isGoal) && !step.isUnlocked)
                    
                    // Tampilkan gambar goal kalau user sudah toggle untuk step goal ini.
                    if step.isGoalImageVisible {
                        let image = viewModel.goalImagesByEndStep[step.id] ?? goalImage
                        ImageGoalView(goalImage: image)
                            .offset(x: 0, y: -160)
                    }
                    
                    if step.isCheckpoint && step.isUnlocked && !step.isClaimed {
                        Button {
                            SoundManager.shared.play(.reward)
                            onTap(step)
                        } label: {
                            Image("claim_button")
                        }
                        .offset(x: 0, y: -80)
                    }
                }
                .padding(.vertical, 0)
            }
        }
        .padding(.top, 220)
        .frame(width: viewModel.requiredWidth)
    }
}

extension CircleStepView where LeadingContent == EmptyView {
    init(
        viewModel: CircleStepViewModel,
        goalImage: UIImage? = nil,
        onTap: @escaping (StepDisplayModel) -> Void
    ){
        self.init(viewModel: viewModel, goalImage: goalImage, leadingContent: { EmptyView() }, onTap: onTap)
    }
}

#Preview {
    ZStack {
        Color(.sRGB, red: 0.08, green: 0.32, blue: 0.40).ignoresSafeArea()
        ScrollView {
            CircleStepView(
                viewModel: CircleStepViewModel(goalSteps: [10], passedSteps: 8)
            ) { step in
                print("Tapped step:", step.id)
            }
            .padding(.vertical, 40)
        }
    }
}
