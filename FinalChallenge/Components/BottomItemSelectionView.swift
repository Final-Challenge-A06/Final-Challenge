import SwiftUI

struct BottomItemSelectionView: View {
    @ObservedObject var viewModel: BottomItemSelectionViewModel

    var body: some View {
        ZStack(alignment: .leading) {
            Image("frame_bottom")

            if viewModel.items.isEmpty {
                HStack {
                    Text("Unlock collections by earning rewards")
                        .font(.custom("audiowide", size: 30))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                            contentReward(for: item)
                                .frame(width: 160, height: 100)
                                .contentShape(Rectangle())
                                .onTapGesture { viewModel.handleTap(on: item) }
                                .overlay(alignment: .trailing) {
                                    if index < viewModel.items.count - 1 {
                                        separator
                                            .frame(height: 88)
                                            .offset(x: 12)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
    }
    
    private var separator: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.15),
                        Color.white.opacity(0.6),
                        Color.white.opacity(0.15)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 3)
            .shadow(color: .white.opacity(0.25), radius: 2, x: 0, y: 0)
            .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 0)
    }

    @ViewBuilder
    private func contentReward(for item: RewardState) -> some View {
        switch viewModel.presentation(for: item) {
        case .claimed(let imageName):
            Image(uiImage: UIImage(named: imageName) ?? UIImage(systemName: "gift.fill")!)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 80)

        case .claimable:
            VStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                Text("Tap to claim")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }

        case .locked:
            Image(systemName: "lock.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

#Preview {
    let demoItems: [RewardState] = []
    let vm = BottomItemSelectionViewModel(items: demoItems)
    return ZStack {
        Color(.sRGB, red: 0.08, green: 0.32, blue: 0.40).ignoresSafeArea()
        BottomItemSelectionView(viewModel: vm)
            .padding()
    }
}
