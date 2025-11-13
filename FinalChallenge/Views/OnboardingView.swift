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
    @StateObject private var goalVM = GoalViewModel()

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
                            .allowsHitTesting(false)
                        
                        Image("ss_before")
                            .resizable()
                            .frame(width: 246, height: 246)
                            .offset(y: 300)
                            .allowsHitTesting(false)
                        
                        Image("modal_bottom_shadow")
                            .offset(x:-10, y: 200)
                            .allowsHitTesting(false)
                        
                        Image("modal_onboarding")
                            .offset(y: -100)
                            .allowsHitTesting(false)
                        
                        HStack {
                            Button {
                                onboardingVM.previous()
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
                            
                            VStack (spacing: 50){
                                Text(onboardingVM.currentPage?.title ?? "")
                                    .font(.custom("audiowide", size: 24))
                                    .foregroundStyle(Color(.white))
                                
                                if let imageName = onboardingVM.currentPage?.imageName {
                                    Image(imageName)
                                }
                                
                                if onboardingVM.currentIndex < onboardingVM.pages.count - 1 {
                                    Text(onboardingVM.currentPage?.description ?? "")
                                        .font(.custom("audiowide", size: 14))
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(Color(.white))
                                        .frame(width: 300)
                                }
                                
                                if onboardingVM.currentIndex == max(onboardingVM.pages.count - 1, 0) {
                                    NavigationLink {
                                        GoalModalStep1View(
                                            vm: goalVM,
                                            bottomItemsVM: bottomItemsVM,
                                            onNext: {} // tidak dipakai lagi
                                        )
                                        .navigationBarBackButtonHidden(true)
                                    } label: {
                                        Text("Let's Begin")
                                            .font(.custom("audiowide", size: 16))
                                            .foregroundStyle(.white)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 100)
                                            .background(Color.yellowButton)
                                            .cornerRadius(20)
                                    }
                                }
                                
                                HStack {
                                    ForEach(onboardingVM.pages.indices, id: \.self) { index in
                                        
                                        Circle()
                                            .fill(index == onboardingVM.currentIndex ? Color.white : Color.white.opacity(0.4))
                                            .frame(width: 8, height: 8)
                                    }
                                }
                            }
                            .offset(y: -100)
                            
                            Button {
                                onboardingVM.next()
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
                                .offset(x: page.offsetX, y: page.offsetY)
                                .rotationEffect(.degrees(page.rotationDegrees))
                        } else if onboardingVM.currentPage == nil {
                            Image("robot")
                                .offset(x: -400, y: -240)
                                .rotationEffect(.degrees(20))
                        }
                    }
                    
                    BottomItemSelectionView(viewModel: bottomItemsVM)
                        .padding(.horizontal, 40)
                        .offset(y: -80)
                }
                .offset(y: 160)
            }
        }
    }
}

private struct OnboardingPreviewContainer: View {
    @StateObject var vm = OnboardingViewModel()
    @StateObject var bottomItemsVM = BottomItemSelectionViewModel()
    
    var body: some View {
        OnboardingView(onboardingVM: vm, bottomItemsVM: bottomItemsVM)
    }
}

#Preview {
    OnboardingPreviewContainer()
}
