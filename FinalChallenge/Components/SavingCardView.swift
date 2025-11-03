import SwiftUI

struct SavingCardView: View {
    let title: String
    let totalSaving: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text(totalSaving)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.sRGB, red: 0.02, green: 0.43, blue: 0.51).opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
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
