//
//  ChatView.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 14/11/25.
//

import SwiftUI

struct ChatView: View {
    var text: String
    
    var body: some View {
        ZStack() {
            Text(text)
                .font(.custom("audiowide", size: 20))
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
        }
    }
}

#Preview {
    ChatView(text: "Hello World!")
}
