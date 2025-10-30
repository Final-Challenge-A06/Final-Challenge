//
//  MaskotView.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 30/10/25.
//

import SwiftUI

struct MaskotView: View {
    var body: some View {
        VStack() {
            ChatBubbleView(text: "Let’s start! Try putting some\nmoney into your piggy bank.")
                .offset(x: 120)
            
            Image("mascotBot")
                .resizable()
                .scaledToFit()
                .frame(width: 130)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.leading, 100)
        .padding(.bottom, 300)
    }
}

#Preview {
    MaskotView()
}
