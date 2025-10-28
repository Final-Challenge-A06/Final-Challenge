import SwiftUI

struct BottomItemSelectionView: View {
    let goalOrange: Color
    let greenBackground: Color
    @State private var isExpanded = true
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            greenBackground
                .frame(height: 180)
            
            HStack(spacing: 24) {
                ForEach(0..<4) { index in
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(goalOrange)
                        .frame(width: 160, height: 100)
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
                        .overlay {
                            if index == 0 {
                                Image("glasses")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 170)
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                        }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            } label: {
                Image("glasses")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 55)
                    .padding(8)
                    .background(goalOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            }
            .contentShape(Rectangle())
            .offset(x: 50, y: -70)
            .zIndex(2)
        }
        .offset(y: isExpanded ? 0 : 100)
    }
}

#Preview {
    BottomItemSelectionView(
        goalOrange: .orange,
        greenBackground: .green.opacity(0.6)
    )
}
