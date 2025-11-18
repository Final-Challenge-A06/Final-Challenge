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
                            contentReward(
                                for: item,
                                isSelected: viewModel.selectedID == item.id
                            )
                            .frame(width: 160, height: 120)
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
    private func contentReward(for item: RewardState, isSelected: Bool) -> some View {
        switch viewModel.presentation(for: item) {
        case .claimed(let imageName):
            VStack(spacing: 6) {
                if isSelected && viewModel.animatingID == item.id {
                    AnimatedAccessoryView(baseName: imageName)
                        .frame(width: 120, height: 80)
                } else {
                    Image("\(imageName)1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 80)
                }

                radioCircle(isSelected: isSelected)
            }
            
        case .claimable:
            VStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                
                radioCircle(isSelected: false, enabled: false)
            }
            
        case .locked:
            VStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                
                radioCircle(isSelected: false, enabled: false)
            }
        }
    }
    
    private func radioCircle(isSelected: Bool, enabled: Bool = true) -> some View {
        ZStack {
            Circle()
                .strokeBorder(
                    enabled ? Color.white.opacity(0.9) : Color.white.opacity(0.3),
                    lineWidth: 2
                )
                .frame(width: 20, height: 20)
            
            if isSelected {
                Circle()
                    .fill(Color.yellow.opacity(0.9))
                    .frame(width: 10, height: 10)
            }
        }
        .opacity(enabled ? 1.0 : 0.4)
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
