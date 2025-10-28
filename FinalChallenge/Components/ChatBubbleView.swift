import SwiftUI

struct ChatBubbleView: View {
    var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(white: 0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .frame(width: 200, height: 60)

            Text(text)
                .font(.footnote)
                .foregroundStyle(.black.opacity(0.8))
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(width: 200, alignment: .leading)
        }
    }
}

#Preview {
    ChatBubbleView(text: "Let’s start! Try putting some\nmoney into your piggy bank.")
}
