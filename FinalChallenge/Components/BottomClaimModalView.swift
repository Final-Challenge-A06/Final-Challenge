//
//  BottomClaimModalView.swift
//  FinalChallenge
//
//  Created by Assistant on 01/11/25.
//

import SwiftUI

struct BottomClaimModalView: View {
    let title: String
    let imageName: String
    var onCancel: () -> Void
    var onClaim: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Claim Reward")
                .font(.title2.bold())

            Image(uiImage: UIImage(named: imageName) ?? UIImage(systemName: "gift.fill")!)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 100)

            Text(title)
                .font(.headline)

            HStack(spacing: 12) {
                Button("Cancel", action: onCancel)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.black.opacity(0.1)))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .buttonStyle(.plain)

                Button("Claim") {
                    onClaim()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.black)
                .background(Color(.sRGB, red: 0.91, green: 0.55, blue: 0.30))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(Color(red: 0.83, green: 0.95, blue: 0.90))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.black.opacity(0.08)))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 8)
        .frame(width: 420)
    }
}

#Preview {
    BottomClaimModalView(title: "Glasses", imageName: "glasses", onCancel: {}, onClaim: {})
        .padding()
        .background(Color.gray.opacity(0.15))
}

