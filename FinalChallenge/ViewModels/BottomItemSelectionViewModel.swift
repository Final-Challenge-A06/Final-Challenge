//
//  BottomItemSelectionViewModel.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 02/11/25.
//

import Foundation
import Combine

final class BottomItemSelectionViewModel: ObservableObject {
    @Published private(set) var items: [RewardViewData] = []

    /// Callback opsional untuk memberi tahu parent saat ada interaksi
    var onSelect: ((RewardViewData) -> Void)?

    init(items: [RewardViewData] = [], onSelect: ((RewardViewData) -> Void)? = nil) {
        self.items = items
        self.onSelect = onSelect
    }

    /// Inject / refresh data dari luar (misal dari GoalView)
    func setItems(_ newItems: [RewardViewData]) {
        items = newItems
    }

    /// Logic saat slot ditekan:
    /// - claimable -> jadi claimed
    /// - claimed / locked -> tetap (atau bisa tampilkan alert jika perlu)
    func handleTap(on item: RewardViewData) {
        guard let idx = items.firstIndex(of: item) else { return }

        switch items[idx].state {
        case .claimable:
            items[idx].state = .claimed
            onSelect?(items[idx])              // beritahu parent
        case .claimed, .locked:
            onSelect?(items[idx])              // tetap beritahu parent bila ingin
        }
    }

    // MARK: - Presentation mapping (UI-agnostic)
    enum RewardPresentation: Equatable {
        case claimed(imageName: String)
        case claimable
        case locked
    }

    func presentation(for item: RewardViewData) -> RewardPresentation {
        switch item.state {
        case .claimed:
            return .claimed(imageName: item.imageName)
        case .claimable:
            return .claimable
        case .locked:
            return .locked
        }
    }
}

