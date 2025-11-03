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

    /// Pangkal callback kalau parent ingin merespons (opsional)
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
}
