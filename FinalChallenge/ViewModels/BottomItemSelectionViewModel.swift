//
//  BottomItemSelectionViewModel.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 02/11/25.
//

import Foundation
import Combine

final class BottomItemSelectionViewModel: ObservableObject {
    @Published private(set) var items: [RewardState] = []
    
    var onSelect: ((RewardState) -> Void)? // Dipanggil saat item dipilih dari UI.

    // Inisialisasi VM dengan daftar item awal dan callback seleksi.
    init(items: [RewardState] = [], onSelect: ((RewardState) -> Void)? = nil) {
        self.items = items
        self.onSelect = onSelect
    }

    // Ganti seluruh daftar item yang ditampilkan.
    func setItems(_ newItems: [RewardState]) {
        items = newItems
    }
    
    // Tangani tap: jika claimable ubah ke claimed lalu panggil callback; lainnya hanya panggil callback.
    func handleTap(on item: RewardState) {
        guard let idx = items.firstIndex(of: item) else { return }

        switch items[idx].state {
        case .claimable:
            items[idx].state = .claimed
            onSelect?(items[idx])
        case .claimed, .locked:
            onSelect?(items[idx])
        }
    }
    
    enum RewardPresentation: Equatable {
        case claimed(imageName: String)
        case claimable
        case locked
    }

    // Petakan item ke bentuk presentasi UI (claimed/claimable/locked).
    func presentation(for item: RewardState) -> RewardPresentation {
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

