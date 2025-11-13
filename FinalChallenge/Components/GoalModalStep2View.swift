//
//  GoalModalStep1View.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI
import SwiftData

struct GoalModalStep2View: View {
    @ObservedObject var vm: GoalViewModel
    var onDone: () -> Void
    var onBack: () -> Void
    
    @State private var showConfirm = false
    @Environment(\.modelContext) private var context
    
    private let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    
    var body: some View {
        ZStack {
            Image("background_main")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Image("frame_top")
                .offset(y: -30)
            
            Image("modal_setgoal")
                .offset(y: -100)
            
            Image("ss_before")
                .resizable()
                .frame(width: 246, height: 246)
                .offset(y: 370)
            
            Image("modal_bottom_shadow")
                .offset(x: -10, y: 270)
            
            BottomItemSelectionView(viewModel: BottomItemSelectionViewModel())
                .offset(x: 50, y: 580)
            
            Image("robot")
                .resizable()
                .frame(width: 200, height: 250)
                .offset(x: 400, y: 300)
                .rotationEffect(.degrees(5))
            
            Text("""
                 When will you save? 
                 Pick your days and how much each time!
                 """)
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
                .offset(x: 200, y: 220)
            
            VStack(alignment: .leading, spacing: 30) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 10, height: 20)
                        .foregroundStyle(Color.black)
                        .padding(15)
                        .background(Color.yellowButton, in: Circle())
                }
                
                Text("Pick your saving days")
                    .font(.custom("audiowide", size: 24))
                    .foregroundStyle(Color.white)
                
                VStack(spacing: 18) {
                    HStack(spacing: 40) {
                        ForEach(days.prefix(4), id: \.self) { day in
                            DayChipView(
                                title: day,
                                isSelected: vm.selectedDays.contains(day)
                            ) { toggle(day) }
                        }
                    }
                    
                    HStack(spacing: 40) {
                        ForEach(days.suffix(3), id: \.self) { day in
                            DayChipView(
                                title: day,
                                isSelected: vm.selectedDays.contains(day),
                            ) { toggle(day) }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Text("How much will you save each time?")
                    .font(.custom("audiowide", size: 24))
                    .foregroundStyle(Color.white)
                
                TextField("", text: $vm.amountText)
                    .keyboardType(.numberPad)
                    .onChange(of: vm.amountText) {
                        let v = vm.amountText
                        let digits = v.filter(\.isNumber)
                        if digits != v { vm.amountText = digits }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(.greenButton, in: RoundedRectangle(cornerRadius: 12))
                
                HStack(spacing: 16) {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                            showConfirm = true
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.black)
                            .padding(16)
                            .background(vm.isStep2Valid ? Color.yellow.opacity(0.8) : Color.gray.opacity(0.4), in: Circle())
                            .padding(.vertical, 16)
                            .padding(.horizontal, 60)
                            .background(.yellowButton, in: Capsule())
                    }
                    .disabled(!vm.isStep2Valid)
                    
                    Spacer()
                }
            }
            .frame(width: 550,  height: 700)
            .offset(y: -100)
            
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
                        
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
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
