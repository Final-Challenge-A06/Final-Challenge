//
//  OnboardingViewModel.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 11/11/25.
//

import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published private(set) var pages: [OnboardingModel]
    @Published var currentIndex: Int = 0

    var currentPage: OnboardingModel? {
        guard pages.indices.contains(currentIndex) else { return nil }
        return pages[currentIndex]
    }

    init(pages: [OnboardingModel] = OnboardingModel.defaultPages) {
        self.pages = pages
    }

    func next() {
        guard currentIndex + 1 < pages.count else { return }
        currentIndex += 1
    }

    func previous() {
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1
    }
}
