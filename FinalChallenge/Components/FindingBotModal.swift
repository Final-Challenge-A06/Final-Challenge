import SwiftUI

struct FindingBotModal: View {
    var connectedName: String?
    var onClose: () -> Void
    var onSetup: () -> Void
    
    var body: some View {
        ZStack {
            Image("background_modal")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            
            Image("modal_finding_bot")
                .resizable()
                .scaledToFit()
                .frame(width: 550)
            
            Button(action: {
                SoundManager.shared.play(.buttonCloseClick)
                onClose()
            }) {
                Image("close_button")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            .buttonStyle(.plain)
            .offset(x: 200, y: -205)
            
            VStack(spacing: 16) {
                Text("Finding Bot...")
                    .font(.custom("Audiowide", size: 30))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                Image("robot")
                    .resizable()
                    .frame(width: 150, height: 200)
                    .scaledToFit()
                
                if let name = connectedName, !name.isEmpty {
                    Text(name)
                        .font(.custom("Audiowide", size: 24))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Button(action: {
                    SoundManager.shared.play(.buttonClick)
                    onSetup()
                }) {
                    Text("Connect")
                        .font(.custom("Audiowide", size: 24))
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

#Preview {
    ZStack {
        Color.black.opacity(0.5).ignoresSafeArea()
        FindingBotModal(
            connectedName: "Billo",
            onClose: {},
            onSetup: {}
        )
    }
}
