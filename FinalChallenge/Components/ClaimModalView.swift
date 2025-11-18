import SwiftUI

struct ClaimModalView: View {
    let title: String
    let imageBaseName: String
    var onClaim: () -> Void
    
    var body: some View {
        ZStack {
            Image("modal_bottom_shadow")
                .offset(y: 380)
            
            Image("modal_setgoal")
            
            VStack(spacing: 20) {
                Text("New Acessories")
                    .font(.custom("audiowide", size: 30))
                    .bold()
                    .foregroundStyle(Color.white)
                
                Text(title)
                    .font(.custom("audiowide", size: 24))
                    .foregroundStyle(Color.white)
                
                AnimatedAccessoryView(baseName: imageBaseName)
                                    .frame(width: 200, height: 200)
                
                Text("Now Billo can look cooler with Accessory")
                    .font(.custom("audiowide", size: 24))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                
                Button {
                    onClaim()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.black)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 50)
                        .background(Color.yellow.opacity(0.7), in: Capsule())
                }
                .offset(y: 40)
            }
            .frame(width: 500)
        }
    }
}

#Preview {
    ClaimModalView(
        title: "Blinking Blue Eyes",
        imageBaseName: "mataNgedipBiru",
        onClaim: {}
    )
}

