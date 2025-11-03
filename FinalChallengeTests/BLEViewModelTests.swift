//
//  BLEViewModelTests.swift
//  FinalChallenge
//
//  Created by Euginia Gabrielle on 03/11/25.
//

import Testing
import Foundation
@testable import FinalChallenge

@Suite("All Case")
struct BLEViewModelTests {
    
    @MainActor
    @Suite("Positive Case")
    struct BLEViewModelPositiveTests {
        var goalVM: GoalViewModel!
        var bleVM: BLEViewModel!
        
        init() {
            goalVM = GoalViewModel()
            bleVM = BLEViewModel(goalVM: goalVM)
        }
        
        @Test("Data BLE valid - trigger menabung")
        func testBLEValidTrigger() async throws {
            let triggerData = "TRIGGER".data(using: .utf8)!
            bleVM.mgr.onValueUpdate?(triggerData)
        }
    }
}
