import SwiftUI

struct ChatBubbleView: View {
    @ObservedObject var model: ChatModel
    var index: Int? = nil
    var enableTypewriter: Bool = true

    private var displayedText: String {
        if let i = index, model.messages.indices.contains(i) {
            return model.messages[i]
        } else if enableTypewriter {
            return model.typedText
        } else {
            return model.currentText
        }
    }

    var body: some View {
        ZStack() {
            Text(displayedText)
                .font(.custom("audiowide", size: 20))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: 250, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    Rectangle()
                        .fill(Color.darkBlue)
                )
        }
        .onAppear {
            if enableTypewriter && index == nil {
                model.startTypingAnimation()
            }
        }
        .onChange(of: model.currentIndex) { _, _ in
            if enableTypewriter && index == nil {
                model.startTypingAnimation()
            }
        }
    }
}

#Preview {
    let vm = ChatModel()
    return VStack(spacing: 16) {
        ChatBubbleView(model: vm)
        ChatBubbleView(model: vm, index: 1)
    }
}
