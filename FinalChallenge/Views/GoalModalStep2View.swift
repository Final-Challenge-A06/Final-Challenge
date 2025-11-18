//
//  GoalModalStep1View.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI

struct GoalModalStep2View: View {
    @ObservedObject var vm: GoalViewModel
    var onDone: () -> Void
    var onBack: () -> Void
    
    @State private var showConfirm = false
    @Environment(\.modelContext) private var context
    
    // Animation states
    @State private var robotOffset: CGFloat = 0
    @State private var robotRotation: Double = 5
    @State private var dialogOpacity: Double = 0
    @State private var dialogScale: Double = 0.8
    @State private var dialogOffset: CGFloat = 0
    @State private var dialogRotation: Double = 0
    @State private var formOffset: CGFloat = -50
    @State private var formOpacity: Double = 0
    @State private var frameOffset: CGFloat = -50
    @State private var modalOffset: CGFloat = -150
    @State private var bottomShadowOpacity: Double = 0
    @State private var buttonScale: Double = 1.0
    @State private var dayChipsScale: [String: Double] = [:]
    @State private var backButtonRotation: Double = 0
    @State private var displayedText: String = ""
    
    private let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    private let fullDialogText = "When will you save?\nPick your days and how much each time!"
    
    var body: some View {
        ZStack {
            Image("background_main")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Image("frame_top")
                .offset(y: frameOffset)
            
            Image("modal_setgoal")
                .offset(y: modalOffset)
            
            Image("ss_before")
                .resizable()
                .frame(width: 246, height: 246)
                .offset(y: 370)
            
            Image("modal_bottom_shadow")
                .offset(x: -10, y: 270)
                .opacity(bottomShadowOpacity)
            
            BottomItemSelectionView(viewModel: BottomItemSelectionViewModel())
                .offset(x: 50, y: 580)
            
            Image("robot")
                .resizable()
                .frame(width: 200, height: 250)
                .offset(x: 400, y: 300 + robotOffset)
                .rotationEffect(.degrees(robotRotation))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
            
            Text(displayedText)
            .font(.custom("audiowide", size: 16))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: 250, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .background(
                Rectangle()
                    .fill(Color.darkBlue)
            )
            .offset(x: 200, y: 220 + dialogOffset)
            .rotationEffect(.degrees(dialogRotation))
            .opacity(dialogOpacity)
            .scaleEffect(dialogScale)
            
            VStack(alignment: .leading, spacing: 30) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 10, height: 20)
                        .foregroundStyle(Color.black)
                        .padding(15)
                        .background(Color.yellow.opacity(0.7), in: Circle())
                }
                
                Text("Pick your saving days")
                    .font(.custom("audiowide", size: 24))
                    .foregroundStyle(Color.white)
                
                VStack(spacing: 18) {
                    HStack(spacing: 40) {
                        ForEach(Array(days.prefix(4).enumerated()), id: \.element) { index, day in
                            DayChipView(
                                title: day,
                                isSelected: vm.selectedDays.contains(day)
                            ) { toggle(day) }
                            .scaleEffect(dayChipsScale[day] ?? 0)
                        }
                    }
                    
                    HStack(spacing: 40) {
                        ForEach(Array(days.suffix(3).enumerated()), id: \.element) { index, day in
                            DayChipView(
                                title: day,
                                isSelected: vm.selectedDays.contains(day)
                            ) { toggle(day) }
                            .scaleEffect(dayChipsScale[day] ?? 0)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Text("How much will you save each time?")
                    .font(.custom("audiowide", size: 24))
                    .foregroundStyle(Color.white)
                
                TextField("", text: $vm.amountText)
                    .keyboardType(.numberPad)
                    .onChange(of: vm.amountText) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            vm.amountText = filtered
                        }
                        vm.validateStep2()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.greenButton.opacity(100/255), in: RoundedRectangle(cornerRadius: 12))
                
                if vm.amountValue > 0 && vm.amountValue < 1_000 {
                    Text("Minimum amount per save is Rp1.000.")
                        .font(.custom("Audiowide", size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 2)
                        .transition(.opacity)
                }
                
                if vm.amountValue > vm.priceValue && vm.priceValue > 0 {
                    Text("Amount per save can't be bigger than your target saving.")
                        .font(.custom("Audiowide", size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 2)
                        .transition(.opacity)
                }
                
                HStack(spacing: 16) {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                            showConfirm = true
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.black)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 50)
                            .background(
                                vm.isStep2Valid
                                ? Color.yellow.opacity(0.7)
                                : Color.gray.opacity(0.4),
                                in: Capsule()
                            )
                            .scaleEffect(vm.isStep2Valid ? buttonScale : 1.0)
                            .shadow(color: vm.isStep2Valid ? .yellow.opacity(0.5) : .clear, radius: 10)
                    }
                    .disabled(!vm.isStep2Valid)
                    
                    Spacer()
                }
            }
            .frame(width: 550,  height: 700)
            .offset(x: formOffset, y: -100)
            .opacity(formOpacity)
            
            if showConfirm {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showConfirm = false
                        }
                    }
                    .transition(.opacity)
                
                ConfirmGoalModalView(
                    isPresented: $showConfirm,
                    onConfirm: {
                        vm.saveGoal(context: context)
                        onDone()
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showConfirm = false
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Robot floating animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            robotOffset = -15
        }
        
        // Robot subtle rotation
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            robotRotation = 10
        }
        
        // Frame and modal slide in
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            frameOffset = -30
            modalOffset = -100
        }
        
        // Dialog bubble appear
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
            dialogOpacity = 1
            dialogScale = 1.0
        }
        
        // Start typewriter effect after dialog appears
        startTypewriterEffect(delay: 0.8)
        
        // Dialog floating animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            dialogOffset = -15
        }
        
        // Dialog subtle rotation
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            dialogRotation = -2
        }
        
        // Form slide in from left
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.6)) {
            formOffset = 0
            formOpacity = 1
        }
        
        // Shadow fade in
        withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
            bottomShadowOpacity = 1
        }
        
        // Day chips cascade animation
        for (index, day) in days.enumerated() {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.8 + Double(index) * 0.1)) {
                dayChipsScale[day] = 1.0
            }
        }
        
        // Back button subtle wobble
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(1.0)) {
            backButtonRotation = 5
        }
        
        // Button pulse animation when valid
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(1.5)) {
            buttonScale = 1.08
        }
    }
    
    private func startTypewriterEffect(delay: Double) {
        Task {
            try? await Task.sleep(for: .seconds(delay))
            
            for character in fullDialogText {
                displayedText.append(character)
                // Faster for spaces and punctuation, slower for letters
                let sleepDuration = character == " " || character == "\n" ? 0.02 : 0.04
                try? await Task.sleep(for: .seconds(sleepDuration))
            }
        }
    }
    
    private func toggle(_ day: String) {
        if vm.selectedDays.contains(day) {
            vm.selectedDays.remove(day)
        } else {
            vm.selectedDays.insert(day)
        }
    }
}

#Preview {
    GoalModalStep2View(vm: GoalViewModel(), onDone: {}, onBack: {})
}
