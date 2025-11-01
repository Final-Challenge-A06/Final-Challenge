//
//  RewardEntity.swift
//  FinalChallenge
//
//  Created by Assistant on 01/11/25.
//

import Foundation
import SwiftData

@Model
final class RewardEntity {
    // id unik
    @Attribute(.unique) var id: String
    // step checkpoint yang membuka reward ini
    var unlockedAtStep: Int
    // nama aset gambar
    var imageName: String
    // judul/nama reward (opsional untuk UI)
    var title: String
    // status sudah diklaim
    var claimed: Bool
    // tanggal klaim (opsional)
    var claimedAt: Date?

    init(
        id: String,
        unlockedAtStep: Int,
        imageName: String,
        title: String,
        claimed: Bool = false,
        claimedAt: Date? = nil
    ) {
        self.id = id
        self.unlockedAtStep = unlockedAtStep
        self.imageName = imageName
        self.title = title
        self.claimed = claimed
        self.claimedAt = claimedAt
    }
}

