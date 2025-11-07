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
    private let goalOrange = Color(red: 0.91, green: 0.55, blue: 0.30)
    private let cardMint   = Color(red: 0.83, green: 0.95, blue: 0.90)

    var body: some View {
        ZStack(alignment: .center) {
            Image("modal")
            
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 10, height: 18)
                            .bold()
                            .foregroundStyle(Color.black)
                        
                        Text("Back")
                            .font(Font.custom("audiowide", size: 20))
                            .foregroundStyle(Color.black)
                    }
                }
                
                Spacer()
                
                Text("Pick your saving days").font(.custom("audiowide", size: 24))

                VStack(spacing: 18) {
                    HStack(spacing: 40) {
                        ForEach(days.prefix(4), id: \.self) { day in
                            DayChipView(
                                title: day,
                                isSelected: vm.selectedDays.contains(day),
                                goalOrange: goalOrange
                            ) { toggle(day) }
                        }
                    }

                    HStack(spacing: 40) {
                        ForEach(days.suffix(3), id: \.self) { day in
                            DayChipView(
                                title: day,
                                isSelected: vm.selectedDays.contains(day),
                                goalOrange: goalOrange
                            ) { toggle(day) }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()

                Text("How much will you save each time?").font(.custom("audiowide", size: 24))

                TextField("e.g., 180000", text: $vm.amountText)
                    .keyboardType(.numberPad)
                    .onChange(of: vm.amountText) { _, newValue in
                        let digits = newValue.filter(\.isNumber)
                        if digits != newValue { vm.amountText = digits }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                
                Spacer()

                HStack(spacing: 16) {
                    Spacer()
                    
                    Button(action: { onDone() }) {
                        Image(systemName: "arrow.right")
                            .foregroundStyle(Color.black)
                            .padding(16)
                            .background(.yellow.opacity(0.6), in: Circle())
                            .disabled(!vm.isStep2Valid)
                    }
                    
                    Spacer()
                }
            }
            .frame(width: 480,  height: 550)
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
        .background(Color.gray.opacity(0.15))
}
