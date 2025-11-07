import SwiftUI

struct BottomItemSelectionView: View {
    @ObservedObject var viewModel: BottomItemSelectionViewModel

    private let itemWidth: CGFloat = 160
    private let itemHeight: CGFloat = 100
    private let hSpacing: CGFloat = 24

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial.opacity(0.4))
                .frame(height: 140)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: hSpacing) {
                    ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                        // Hanya konten, tanpa kartu latar per-item
                        content(for: item)
                            .frame(width: itemWidth, height: itemHeight)
                            .contentShape(Rectangle())
                            .onTapGesture { viewModel.handleTap(on: item) }
                            // Tambahkan separator di kanan setiap item kecuali yang terakhir
                            .overlay(alignment: .trailing) {
                                if index < viewModel.items.count - 1 {
                                    separator
                                        .frame(height: itemHeight - 12)
                                        .offset(x: hSpacing / 2) // sejajarkan dengan spacing HStack
                                }
                            }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
        }
    }

    // Garis pemisah vertikal dengan efek highlight seperti contoh
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
    private func content(for item: RewardState) -> some View {
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
    let demoItems: [RewardState] = [
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
