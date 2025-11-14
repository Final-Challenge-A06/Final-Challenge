import Foundation

struct RewardModel: Identifiable, Equatable {
    let id: String
    let step: Int
    let title: String
    let imageName: String
}

struct RewardState: Identifiable, Equatable {
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
