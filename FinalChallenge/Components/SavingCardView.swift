import SwiftUI

struct SavingCardView: View {
    let title: String
    let totalSaving: String
    var backgroundColor: Color = Color(.sRGB, red: 0.02, green: 0.43, blue: 0.51)
    var cornerRadius: CGFloat = 22
    var horizontalPadding: CGFloat = 24
    var verticalPadding: CGFloat = 20
    var shadowColor: Color = .black.opacity(0.25)
    var shadowRadius: CGFloat = 10
    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 6
    var strokeColor: Color = Color.white.opacity(0.15)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text(totalSaving)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(backgroundColor.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: shadowColor, radius: shadowRadius, x: shadowX, y: shadowY)
        )
    }
}

#Preview {
    ZStack {
        Color(.sRGB, red: 0.08, green: 0.32, blue: 0.40).ignoresSafeArea()
        HStack {
            SavingCardView(title: "My Saving", totalSaving: "10.000")
            Spacer()
        }
        .padding(.leading, 24)
    }
}
