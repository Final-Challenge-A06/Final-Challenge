import SwiftUI

struct SavingCardView: View {
    let title: String
    let totalSaving: String

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.custom("Audiowide", size: 32))
                .foregroundStyle(.white)
            Text(totalSaving)
                .font(.custom("Audiowide", size: 32))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.ultraThinMaterial)
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
