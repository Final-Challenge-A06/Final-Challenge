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
    @Published var selectedID: String?
    @Published var animatingID: String?
    
    var onSelect: ((RewardState) -> Void)?
    
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
        guard items[idx].state == .claimed else { return }
        
        selectedID = items[idx].id
        animatingID = items[idx].id
        
        // Kirim ke IoT
        NotificationCenter.default.post(
            name: .didSelectAccessory,
            object: nil,
            userInfo: ["photoName": items[idx].imageName]
        )
        
        onSelect?(items[idx])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (0.18 * 7 * 3)) {
            if self.animatingID == item.id {
                self.animatingID = nil
            }
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
        case .claimable, .locked:
            return .locked
        }
    }
}

