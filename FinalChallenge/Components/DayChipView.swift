//
//  DayChipView.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI

struct DayChipView: View {
    static let size: CGFloat = 74
    let title: String
    let isSelected: Bool
    let goalOrange: Color
    let tap: () -> Void

    var body: some View {
        Button(action: tap) {
            ZStack {
                Circle()
                    .fill(isSelected ? goalOrange : .white.opacity(0.25))
                    .overlay(
                        Circle().stroke(isSelected ? .black.opacity(0.15) : .white, lineWidth: isSelected ? 1 : 4)
                    )
                    .frame(width: DayChipView.size, height: DayChipView.size)
                Text(title).font(.headline).foregroundStyle(.black)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}

#Preview {
    DayChipView(
        title: "Mon",
        isSelected: false,
        goalOrange: Color.orange,
        tap: {}
    )
    .padding()
    .background(Color.gray.opacity(0.2))
}
