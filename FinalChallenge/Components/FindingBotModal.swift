import SwiftUI

struct FindingBotModal: View {
    var connectedName: String?
    var onClose: () -> Void
    var onSetup: () -> Void
    
    var body: some View {
        VStack {
            ZStack() {
                Image("background_modal")
                    .resizable()
                    .scaledToFit()
                
                // Background modal image
                Image("modalFindingBot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 450)
                
                // Close button
                Button(action: {
                    SoundManager.shared.play(.buttonCloseClick)
                    onClose()
                }) {
                    Image("closeButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                .buttonStyle(.plain)
                .offset(x: 160, y: -180)
                
                // Content
                VStack(spacing: 8) {
                    Text("Find Bot")
                        .font(.custom("Audiowide", size: 24))
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    
                    Image("robot")
                        .resizable()
                        .frame(width: 128, height: 180)
                        .scaledToFit()
                        .padding(.top, 4)
                    
                    if let name = connectedName, !name.isEmpty {
                        Text(name)
                            .font(.custom("Audiowide", size: 16))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Button(action: {
                        SoundManager.shared.play(.buttonClick)
                        onSetup()
                    }) {
                        Text("Connect")
                            .font(.custom("Audiowide", size: 16))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 100)
                            .background(Color.yellow.opacity(0.7))
                            .cornerRadius(30)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 50)
                }
                .padding(.horizontal, 22)
                .offset(y: -40)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.25).ignoresSafeArea()
        FindingBotModal(
            connectedName: "ESP32 Roboo",
            onClose: {},
            onSetup: {}
        )
    }
}
