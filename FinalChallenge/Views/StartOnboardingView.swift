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
    @State private var goToOnboarding = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background_main")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack () {
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
                            .offset(x:-150, y: 50)
                            .rotationEffect(.degrees(-10))
                        
                        ChatBubbleView(model: chatVM)
                            .offset(y: -50)
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
                    goToOnboarding = true
                }
            }
            .navigationDestination(isPresented: $goToOnboarding) {
                OnboardingDestinationView()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

// Wrapper untuk membuat dependency OnboardingView
private struct OnboardingDestinationView: View {
    @StateObject private var onboardingVM = OnboardingViewModel()
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()
    
    var body: some View {
        OnboardingView(onboardingVM: onboardingVM, bottomItemsVM: bottomItemsVM)
            .navigationBarBackButtonHidden(true) // sembunyikan tombol back di halaman tujuan
    }
}

#Preview {
    StartOnboardingView(bottomItemsVM: BottomItemSelectionViewModel())
}
