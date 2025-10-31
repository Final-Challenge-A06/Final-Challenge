import SwiftUI

struct CircleStepView: View {
    @StateObject private var viewModel: CircleStepViewModel

    // Initializer untuk meneruskan data ke ViewModel
    init(totalSteps: Int, passedSteps: Int) {
        _viewModel = StateObject(wrappedValue: CircleStepViewModel(
            totalSteps: totalSteps,
            passedSteps: passedSteps
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Loop data dari ViewModel, bukan menghitung di sini
            ForEach(viewModel.steps) { step in
                Image(step.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: step.size, height: step.size)
                    .rotationEffect(.degrees(step.rotation))
                    .offset(x: step.xOffset)
            }
        }
        // ViewModel juga memberi tahu kita lebar yang benar
        .frame(width: viewModel.requiredWidth)
    }
}

// Preview tetap sama, tidak akan merusak apa pun
#Preview {
    ZStack {
        Color(.sRGB, red: 0.08, green: 0.32, blue: 0.40)
            .ignoresSafeArea()
        ScrollView {
            CircleStepView(
                totalSteps: 7,
                passedSteps: 2
            )
            .padding(.vertical, 40)
        }
    }
}
