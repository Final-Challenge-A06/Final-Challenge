import SwiftUI

struct FindingBotModal: View {
    var connectedName: String?
    var onClose: () -> Void
    var onSetup: () -> Void
    var onLearnMore: () -> Void
    
    var body: some View {
        VStack {
            ZStack() {
                Image("background_modal")
                
                // Background modal image
                Image("modalFindingBot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 450)
                
                // Close button
                Button(action: onClose) {
                    Image("closeButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                .buttonStyle(.plain)
                .offset(x: 160, y: -180)
                
                // Content
                VStack(spacing: 14) {
                    Text("Find Bot")
                        .font(.custom("Audiowide", size: 24))
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    
                    Image("robot")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 128)
                        .padding(.top, 4)
                    
                    if let name = connectedName, !name.isEmpty {
                        Text(name)
                            .font(.custom("Audiowide", size: 16))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Button(action: onSetup) {
                        Text("Connect")
                            .font(.custom("Audiowide", size: 16))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 100)
                            .background(Color.yellowButton)
                            .cornerRadius(30)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 50)
                }
                .padding(.horizontal, 22)
                .offset(y: -40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.25).ignoresSafeArea()
        FindingBotModal(
            connectedName: "ESP32 Roboo",
            onClose: {},
            onSetup: {},
            onLearnMore: {}
        )
    }
}
