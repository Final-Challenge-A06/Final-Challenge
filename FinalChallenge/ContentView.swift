//
//  ContentView.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 22/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @StateObject private var bottomItemsVM = BottomItemSelectionViewModel()

    var body: some View {
//        OnboardingView(onboardingVM: viewModel, bottomItemsVM: bottomItemsVM)
        BLETestView()
    }
}

#Preview {
    ContentView()
}
