import SwiftUI

struct RewardViewData: Identifiable, Equatable {
    enum State {
        case locked
        case claimable
        case claimed
    }
    
    let id: String
    let title: String
    let imageName: String
    let state: State
}

struct BottomItemSelectionView: View {
    var items: [RewardViewData]
    var onTapSlot: (RewardViewData) -> Void = { _ in }
    
    private let panelTeal = Color(.sRGB, red: 0.02, green: 0.43, blue: 0.51)
    private let panelOverlay = Color.white.opacity(0.10)
    
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
            
            ScrollView (.horizontal, showsIndicators: false){
                HStack(spacing: 24) {
                    ForEach(items) { item in
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 160, height: 100)
                                .overlay {
                                    content(for: item)
                                }
                        }
                        .onTapGesture {
                            onTapSlot(item)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
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
    BottomItemSelectionView(items: [
        RewardViewData(id: "r1", title: "Glasses", imageName: "glasses", state: .claimed),
        RewardViewData(id: "r2", title: "Reward2", imageName: "reward2", state: .claimable),
        RewardViewData(id: "r3", title: "Reward3", imageName: "reward3", state: .locked)
    ])
    .padding()
    .background(Color(.sRGB, red: 0.08, green: 0.32, blue: 0.40))
}

