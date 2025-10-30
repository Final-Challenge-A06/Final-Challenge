//
//  CenteredModal.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI

struct CenteredModal<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.25))
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
                .transition(.opacity)
            
            content
                .transition(.scale.combined(with: .opacity))
                .shadow(color: .black.opacity(0.15), radius: 20, y: 12)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isPresented)
    }
}
