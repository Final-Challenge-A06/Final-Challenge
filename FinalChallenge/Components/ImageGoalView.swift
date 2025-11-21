//
//  ImageGoalView.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 18/11/25.
//

import SwiftUI

struct ImageGoalView: View {
    let goalImage: UIImage?
    
    var body: some View {
        ZStack {
            Image("modal_bottom_shadow")
                .resizable()
                .scaledToFit()
                .offset(y: 90)
            
            Image("modal_gift")
                .resizable()
                .scaledToFit()
            
            if let goalImage = goalImage {
                Image(uiImage: goalImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 5)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
        }
        .offset(y: 20)
    }
}

#Preview {
    ImageGoalView(goalImage: nil)
}
