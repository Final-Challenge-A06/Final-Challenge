//
//  StartOnboardingView.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 12/11/25.
//

import SwiftUI

struct StartOnboardingView: View {
    @ObservedObject var bottomItemsVM: BottomItemSelectionViewModel
    @StateObject private var chatVM = ChatModel()
    @EnvironmentObject var flowVM: AppFlowViewModel
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Image("background_main")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack() {
                ZStack {
                    Image("frame_top")
                    
                    Image("ss_before")
                        .resizable()
                        .frame(width: 246, height: 246)
                        .offset(y: 300)
                    
                    Image(systemName: "lock.fill")
                        .opacity(0.5)
                        .offset(y: 260)
                    
                    Image("robot")
                        .offset(x: -150, y: 50)
                        .rotationEffect(.degrees(-10))
                    
                    ChatBubbleView(model: chatVM)
                        .offset(y: -50)
                    
                    Text("Tap to continue")
                        .font(.custom("Audiowide", size: 18))
                        .foregroundColor(.white)
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                        .offset(y: 420)
                        .onAppear {
                            isPulsing = true
                        }
                }
                
                BottomItemSelectionView(viewModel: bottomItemsVM)
                    .padding(.horizontal, 40)
                    .offset(y: -80)
            }
            .offset(y: 160)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !chatVM.messages.isEmpty else { return }
            let lastIndex = chatVM.messages.count - 1
            if chatVM.currentIndex < lastIndex {
                chatVM.currentIndex += 1
            } else {
                flowVM.goToOnboarding()
            }
        }
    }
}

#Preview {
    StartOnboardingView(bottomItemsVM: BottomItemSelectionViewModel())
        .environmentObject(AppFlowViewModel())
}
