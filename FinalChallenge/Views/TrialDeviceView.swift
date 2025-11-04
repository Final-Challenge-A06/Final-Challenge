//
//  TrialDeviceIntroView.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 04/11/25.
//

import SwiftUI

struct TrialDeviceIntroView: View {
    private let zigzagNormal: CGFloat = 40
    
    var body: some View {
        ZStack {
            Image("bgTrialDevice")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer(minLength: 40)
                
                Text("Fuel Up Bot With Cash")
                    .font(.custom("Audiowide-Regular", size: 30))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .multilineTextAlignment(.center)
                
                Image("piggyBankTrialDevice")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 270)
                    .padding(.top, 10)
                
                VStack(spacing: 18) {
                    ForEach(0..<4, id: \.self) { step in
                        let isLarge = (step == 0 || step == 3)
                        let isLeft = (step % 2 == 0)
                        let xOffset = isLarge ? 0 : (isLeft ? -zigzagNormal : zigzagNormal)
                        
                        Image("ss_before")
                            .resizable()
                            .scaledToFit()
                            .frame(width: isLarge ? 200 : 200)
                            .offset(x: xOffset)
                    }
                }
                .padding(.top, 16)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    TrialDeviceIntroView()
}
