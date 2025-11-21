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
    let tap: () -> Void

    var body: some View {
        Button(action: {
            SoundManager.shared.play(.buttonClick)
            tap()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 34)
                    .fill(isSelected ? .darkBlue : .lightBlue)
                    .frame(width: DayChipView.size, height: DayChipView.size)
                
                Text(title)
                    .font(.custom("audiowide", size: 20, relativeTo: .title))
                    .foregroundStyle(isSelected ? .white : .black)
            }
            .glassEffect()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DayChipView(
        title: "Mon",
        isSelected: false,
        tap: {}
    )
    .padding()
    .background(Color.gray.opacity(0.2))
    
    DayChipView(
        title: "Mon",
        isSelected: true,
        tap: {}
    )
    .padding()
    .background(Color.gray.opacity(0.2))
}
