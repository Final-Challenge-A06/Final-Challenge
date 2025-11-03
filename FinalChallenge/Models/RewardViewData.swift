//
//  RewardViewData.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 02/11/25.
//

import Foundation

struct RewardViewData: Identifiable, Equatable {
    enum State: Equatable {
        case locked
        case claimable
        case claimed
    }

    let id: String
    let title: String
    let imageName: String
    var state: State
}
