//
//  GoalModalStep1View.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI

struct GoalModalStep2View: View {
    var onDone: () -> Void
    var onBack: () -> Void

    @State private var selectedDays: Set<Int> = []
    @State private var amountText = ""

    private let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    private let goalOrange = Color(red: 0.91, green: 0.55, blue: 0.30)
    private let cardMint   = Color(red: 0.83, green: 0.95, blue: 0.90)

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 22) {
                Text("Pick your saving days").font(.title2.bold())

                VStack(spacing: 18) {
                    HStack(spacing: 18) {
                        ForEach(0..<4, id: \.self) { i in
                            DayChipView(title: days[i],
                                    isSelected: selectedDays.contains(i),
                                    goalOrange: goalOrange) { toggle(i) }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    HStack(spacing: 18) {
                        ForEach(4..<7, id: \.self) { i in
                            DayChipView(title: days[i],
                                    isSelected: selectedDays.contains(i),
                                    goalOrange: goalOrange) { toggle(i) }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                Text("How much will you save each time?").font(.headline)

                TextField("e.g., 180000", text: $amountText)
                    .keyboardType(.numberPad)
                    .onChange(of: amountText) { v in
                        let digits = v.filter(\.isNumber)
                        if digits != v { amountText = digits }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black.opacity(0.08)))

                HStack(spacing: 16) {
                    Button("Back", action: onBack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.black.opacity(0.10)))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .buttonStyle(.plain)

                    Button("Done", action: onDone)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.black)
                        .background(goalOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
            .padding(20)
            .background(cardMint)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.black.opacity(0.08)))
            .shadow(color: .black.opacity(0.08), radius: 12, y: 8)
            .frame(width: 560)

            Button {
                onBack()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(8)
                    .background(.white, in: Circle())
                    .shadow(radius: 2)
            }
            .buttonStyle(.plain)
            .padding(10)
        }
    }

    private func toggle(_ i: Int) {
        if selectedDays.contains(i) { selectedDays.remove(i) } else { selectedDays.insert(i) }
    }
}

#Preview {
    GoalModalStep2View(onDone: {}, onBack: {})
        .padding()
        .background(Color.gray.opacity(0.15))
}
