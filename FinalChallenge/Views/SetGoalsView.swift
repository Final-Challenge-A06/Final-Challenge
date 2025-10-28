import SwiftUI

struct SetGoalsView: View {
    private let goalOrange = Color(red: 0.91, green: 0.55, blue: 0.30)
    private let greenBackground = Color(red: 0.75, green: 0.92, blue: 0.68)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea().ignoresSafeArea(edges: .all)
            
            VStack(spacing: 28) {
                Spacer()
                Spacer()
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(goalOrange)
                        .frame(width: 320, height: 320)
                    
                    VStack(spacing: 8) {
                        Text("Set")
                            .font(.largeTitle.bold())
                        Text("Goals")
                            .font(.largeTitle.bold())
                    }
                    
                    Image("robotHead")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .offset(y: -190)
                }
                
                Circle().fill(goalOrange).frame(width: 72, height: 72).offset(x: 32)
                Circle().fill(goalOrange).frame(width: 114, height: 114).offset(x: -32)
                Circle().fill(goalOrange).frame(width: 72, height: 72).offset(x: 32)
                Circle().fill(goalOrange).frame(width: 59, height: 59).offset(x: -44)
                
                Spacer()
                
                BottomItemSelectionView(
                    goalOrange: goalOrange,
                    greenBackground: greenBackground
                )
            }
            
            VStack() {
                ChatBubbleView(text: "Let’s start! Try putting some\nmoney into your piggy bank.")
                    .offset(x: 120)
                
                Image("mascotBot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding(.leading, 100)
            .padding(.bottom, 300)
        }
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    SetGoalsView()
}
