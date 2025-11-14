//
//  RewardEntity.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 13/11/25.
//

import SwiftData
import Foundation

@Model
final class RewardEntity {
    @Attribute(.unique) var id: String
    var unlockedAtStep: Int
    var imageName: String
    var title: String
    var claimed: Bool
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
