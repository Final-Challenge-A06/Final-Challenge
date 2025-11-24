import SwiftUI
import Combine

struct AnimatedAccessoryView: View {
    let baseName: String
    let frameCount: Int = 7
    let loopCount: Int = 3       
    let frameDuration: Double = 0.25

    @State private var currentFrame: Int = 1
    @State private var currentLoop: Int = 0
    @State private var isAnimating: Bool = true

    // Timer untuk ganti frame
    private let timer = Timer.publish(
        every: 0.18,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        Image("\(baseName)\(currentFrame)")
            .resizable()
            .scaledToFit()
            .onAppear {
                currentFrame = 1
                currentLoop = 0
                isAnimating = true
            }
            .onDisappear {
                isAnimating = false
            }
            .onReceive(timer) { _ in
                guard isAnimating else { return }

                currentFrame += 1
                if currentFrame > frameCount {
                    currentFrame = 1
                    currentLoop += 1

                    if loopCount > 0 && currentLoop >= loopCount {
                        isAnimating = false
                    }
                }
            }
    }
}

#Preview {
    AnimatedAccessoryView(baseName: "mataNgedipBiru")
}
