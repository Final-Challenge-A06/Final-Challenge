// FinalChallenge/Components/BottomItemSelectionView.swift
import SwiftUI

struct BottomItemSelectionView: View {
    @ObservedObject var viewModel: BottomItemSelectionViewModel

    private let panelTeal = Color(.sRGB, red: 0.02, green: 0.43, blue: 0.51)

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(panelTeal.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
                .frame(height: 140)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(viewModel.items) { item in
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 160, height: 100)
                            .overlay { content(for: item) }
                            .onTapGesture { viewModel.handleTap(on: item) }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
    }

    @ViewBuilder
    private func content(for item: RewardViewData) -> some View {
        switch item.state {
        case .claimed:
            Image(uiImage: UIImage(named: item.imageName) ?? UIImage(systemName: "gift.fill")!)
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
    // Preview model data
    let demoItems: [RewardViewData] = [
        .init(id: "r1", title: "Glasses", imageName: "glasses", state: .claimed),
        .init(id: "r2", title: "Reward2", imageName: "reward2", state: .claimable),
        .init(id: "r3", title: "Reward3", imageName: "reward3", state: .locked),
        .init(id: "r4", title: "Reward4", imageName: "reward4", state: .locked)
    ]

    let vm = BottomItemSelectionViewModel(items: demoItems)
    return ZStack {
        Color(.sRGB, red: 0.08, green: 0.32, blue: 0.40).ignoresSafeArea()
        BottomItemSelectionView(viewModel: vm)
            .padding()
    }
}
