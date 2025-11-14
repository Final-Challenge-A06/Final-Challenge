//
//  BalanceModel.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 11/11/25.
//

import SwiftData

@Model
final class BalanceModel {
    var balance: Int64
    init(balance: Int64 = 0) { self.balance = balance }
}
