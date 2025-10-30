//
//  GoalModel.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI

struct GoalModel: Identifiable, Equatable {
    let id: UUID
    var name: String
    var price: Int
    var previewImageData: Data?

    init(
        id: UUID = .init(),
        name: String = "",
        price: Int = 0,
        previewImageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.previewImageData = previewImageData
    }
}
