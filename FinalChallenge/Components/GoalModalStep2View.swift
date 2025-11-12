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
    
    private let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    
    var body: some View {
        ZStack(alignment: .center) {
            Image("modal_goal")
            
            VStack(alignment: .leading, spacing: 30) {
                Button(action: { onBack() }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 10, height: 18)
                        .bold()
                        .foregroundStyle(Color.black)
                        .padding(20)
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
                
//                Spacer()
                
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
                
//                Spacer()
                
                HStack(spacing: 16) {
                    Spacer()
                    
                    Button(action: { onDone() }) {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.black)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 60)
                            .background(.yellowButton, in: Capsule())
                            .disabled(!vm.isStep2Valid)
                    }
                    
                    Spacer()
                }
            }
            .frame(width: 550,  height: 700)
        }
        .frame(width: 632, height: 700)
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
        .padding()
}
