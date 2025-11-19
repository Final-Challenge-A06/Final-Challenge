//
//  OnboardingView.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 11/11/25.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    @ObservedObject var bottomItemsVM: BottomItemSelectionViewModel
    @EnvironmentObject var flowVM: AppFlowViewModel
    
    // Animation states
    @State private var typedText: String = ""
    @State private var showTitle: Bool = false
    @State private var showImage: Bool = false
    @State private var showButton: Bool = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var robotBounce: CGFloat = 0
    @State private var contentOpacity: Double = 1.0
    @State private var typingTimer: Timer?
    
    // Entrance animation states
    @State private var showFrameTop: Bool = false
    @State private var showScreenshot: Bool = false
    @State private var showModalShadow: Bool = false
    @State private var showModal: Bool = false
    
    var body: some View {
        ZStack {
            Image("background_main")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack() {
                ZStack {
                    Image("frame_top")
                        .allowsHitTesting(false)
                        .offset(y: showFrameTop ? 0 : -100)
                        .opacity(showFrameTop ? 1 : 0)
                    
                    Image("ss_before")
                        .resizable()
                        .frame(width: 246, height: 246)
                        .offset(y: 300)
                        .allowsHitTesting(false)
                        .scaleEffect(showScreenshot ? 1 : 0.3)
                        .opacity(showScreenshot ? 1 : 0)
                        .rotationEffect(.degrees(showScreenshot ? 0 : -10))
                    
                    Image("modal_bottom_shadow")
                        .offset(x: -10, y: 200)
                        .allowsHitTesting(false)
                        .opacity(showModalShadow ? 1 : 0)
                        .scaleEffect(showModalShadow ? 1 : 0.9)
                    
                    Image("modal_onboarding")
                        .offset(y: showModal ? -100 : 100)
                        .allowsHitTesting(false)
                        .opacity(showModal ? 1 : 0)
                        .scaleEffect(showModal ? 1 : 0.8)
                    
                    HStack {
                        Button {
                            SoundManager.shared.play(.buttonClick)
                            navigatePrevious()
                        } label: {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .frame(width: 15, height: 25)
                                .foregroundStyle(Color(.white))
                        }
                        .padding(24)
                        .contentShape(Rectangle())
                        .opacity(onboardingVM.currentIndex > 0 ? 1 : 0.4)
                        .disabled(onboardingVM.currentIndex == 0)
                        .offset(x: -70, y: -100)
                        
                        VStack(spacing: 50) {
                            Text(onboardingVM.currentPage?.title ?? "")
                                .font(.custom("audiowide", size: 26))
                                .foregroundStyle(Color(.white))
                                .scaleEffect(showTitle ? 1 : 0.5)
                                .opacity(showTitle ? 1 : 0)
                            
                            if let imageName = onboardingVM.currentPage?.imageName {
                                Image(imageName)
                                    .scaleEffect(showImage ? 1 : 0.8)
                                    .opacity(showImage ? 1 : 0)
                                    .rotation3DEffect(
                                        .degrees(showImage ? 0 : 15),
                                        axis: (x: 1, y: 0, z: 0)
                                    )
                            }
                            
                            if onboardingVM.currentIndex < onboardingVM.pages.count - 1 {
                                Text(typedText)
                                    .font(.custom("audiowide", size: 20))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Color(.white))
                                    .frame(width: 300, height: 60, alignment: .top)
                            }
                            
                            if onboardingVM.currentIndex == max(onboardingVM.pages.count - 1, 0) {
                                Button {
                                    SoundManager.shared.play(.buttonClick)
                                    flowVM.startGoalSetup()
                                } label: {
                                    Text("Let's Begin")
                                        .font(.custom("audiowide", size: 16))
                                        .foregroundStyle(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 100)
                                        .background(Color.yellow.opacity(0.7))
                                        .cornerRadius(20)
                                }
                                .scaleEffect(buttonScale)
                                .opacity(showButton ? 1 : 0)
                                .offset(y: showButton ? 0 : 20)
                            }
                            
                            HStack(spacing: 12) {
                                ForEach(onboardingVM.pages.indices, id: \.self) { index in
                                    Circle()
                                        .fill(index == onboardingVM.currentIndex ? Color.white : Color.white.opacity(0.4))
                                        .frame(width: index == onboardingVM.currentIndex ? 10 : 8,
                                               height: index == onboardingVM.currentIndex ? 10 : 8)
                                        .scaleEffect(index == onboardingVM.currentIndex ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: onboardingVM.currentIndex)
                                }
                            }
                        }
                        .offset(y: -100)
                        .opacity(contentOpacity)
                        
                        Button {
                            SoundManager.shared.play(.buttonClick)
                            navigateNext()
                        } label: {
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 15, height: 25)
                                .foregroundStyle(Color(.white))
                        }
                        .padding(24)
                        .contentShape(Rectangle())
                        .opacity(onboardingVM.currentIndex < onboardingVM.pages.count - 1 ? 1 : 0.4)
                        .disabled(onboardingVM.currentIndex >= onboardingVM.pages.count - 1)
                        .offset(x: 70, y: -100)
                    }
                    .zIndex(1)
                    
                    if let page = onboardingVM.currentPage,
                       onboardingVM.currentIndex < onboardingVM.pages.count - 1 {
                        Image("robot")
                            .offset(x: page.offsetX, y: page.offsetY + robotBounce)
                            .rotationEffect(.degrees(page.rotationDegrees))
                            .animation(
                                .easeInOut(duration: 1.0),
                                value: onboardingVM.currentIndex
                            )
                    } else if onboardingVM.currentPage == nil {
                        Image("robot")
                            .offset(x: -400, y: -240 + robotBounce)
                            .rotationEffect(.degrees(20))
                    }
                }
                
                BottomItemSelectionView(viewModel: bottomItemsVM)
                    .padding(.horizontal, 40)
                    .offset(y: -80)
            }
            .offset(y: 160)
        }
        .onAppear {
            startEntranceAnimations()
            startRobotBounce()
        }
        .onChange(of: onboardingVM.currentIndex) { _ in
            resetAndStartAnimations()
        }
    }
    
    // MARK: - Animation Functions
    
    private func startEntranceAnimations() {
        // Animate frame top - slide down from top
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
            showFrameTop = true
        }
        
        // Animate modal - slide up and scale
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.3)) {
            showModal = true
        }
        
        // Animate modal shadow
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            showModalShadow = true
        }
        
        // Animate screenshot - pop in with rotation
        withAnimation(.spring(response: 0.9, dampingFraction: 0.6).delay(0.6)) {
            showScreenshot = true
        }
        
        // Start content animations after entrance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        showTitle = false
        showImage = false
        showButton = false
        typedText = ""
        
        // Animate title
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
            showTitle = true
        }
        
        // Animate image
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            showImage = true
        }
        
        // Start typing effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startTypingEffect()
        }
        
        // Animate button (for last page)
        if onboardingVM.currentIndex == onboardingVM.pages.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.8)) {
                showButton = true
            }
            startButtonPulse()
        }
    }
    
    private func resetAndStartAnimations() {
        // Cancel current typing
        typingTimer?.invalidate()
        typingTimer = nil
        
        // Fade out current content
        withAnimation(.easeOut(duration: 0.15)) {
            contentOpacity = 0.8
        }
        
        // Reset and animate new content
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeIn(duration: 0.15)) {
                contentOpacity = 1.0
            }
            startAnimations()
        }
    }
    
    private func startTypingEffect() {
        guard let description = onboardingVM.currentPage?.description,
              onboardingVM.currentIndex < onboardingVM.pages.count - 1 else {
            return
        }
        
        typedText = ""
        var currentIndex = 0
        let characters = Array(description)
        
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if currentIndex < characters.count {
                typedText.append(characters[currentIndex])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func startRobotBounce() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            robotBounce = -10
        }
    }
    
    private func startButtonPulse() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                buttonScale = 1.05
            }
        }
    }
    
    private func navigateNext() {
        typingTimer?.invalidate()
        onboardingVM.next()
    }
    
    private func navigatePrevious() {
        typingTimer?.invalidate()
        onboardingVM.previous()
    }
}

private struct OnboardingPreviewContainer: View {
    @StateObject var vm = OnboardingViewModel()
    @StateObject var bottomItemsVM = BottomItemSelectionViewModel()
    
    var body: some View {
        OnboardingView(onboardingVM: vm, bottomItemsVM: bottomItemsVM)
            .environmentObject(AppFlowViewModel())
    }
}

#Preview {
    OnboardingPreviewContainer()
}
