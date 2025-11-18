//
//  ConfirmGoalModalView.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 12/11/25.
//

import SwiftUI

struct ConfirmGoalModalView: View {
    @Binding var isPresented: Bool
    var onConfirm: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Are You Sure?")
                .font(.custom("audiowide", size: 24))
                .foregroundStyle(.black)

            Text("Once saved,\nyour goal can’t be changed.\nReady to confirm?")
                .multilineTextAlignment(.center)
                .font(.custom("audiowide", size: 18))
                .foregroundStyle(.black)

            HStack(spacing: 20) {
                Button(action: {
                    onBack()
                    isPresented = false
                }) {
                    Text("Back")
                        .font(.custom("audiowide", size: 18))
                        .foregroundStyle(.black)
                        .frame(width: 130, height: 48)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(24)
                }
                
                Button(action: {
                    onConfirm()
                    isPresented = false
                }) {
                    Text("Confirm")
                        .font(.custom("audiowide", size: 18))
                        .foregroundStyle(.black)
                        .frame(width: 130, height: 48)
                        .background(Color.yellow.opacity(0.7))
                        .cornerRadius(24)
                }
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white)
        )
        .padding(.horizontal, 24)
    }
}

#Preview {
    ConfirmGoalModalView(isPresented: .constant(true), onConfirm: {}, onBack: {})
}

