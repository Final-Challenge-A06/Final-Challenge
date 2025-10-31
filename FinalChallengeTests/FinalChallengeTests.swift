//
//  FinalChallengeTests.swift
//  FinalChallengeTests
//
//  Created by Euginia Gabrielle on 30/10/25.
//

import Testing
import UIKit
@testable import FinalChallenge

@Suite("All Case")
struct FinalChallengeTests {

    @Suite("Positive Cases")
    struct GoalViewModelPositiveTests {
        @MainActor
        @Test("Step 1 modal valid when all fields are filled")
        func testStep1Valid() {
            let vm = GoalViewModel()
            vm.goalName = "Sepeda"
            vm.priceText = "800000"
            vm.selectedImage = UIImage(systemName: "photo")
            vm.validateStep1()
            print(vm.selectedImage ?? "helo")
            
            #expect(vm.isStep1Valid == true)
        }
        
        @MainActor
        @Test("Step 2 modal valid when all fields are filled")
        func testStep2Valid() async throws {
            let vm = GoalViewModel()
            vm.selectedDays = ["Tue, Wed, Fri"]
            vm.amountText = "50000"
            
            #expect(vm.isStep2Valid == true)
        }
        
        @MainActor
        @Test("Price text setter converts string to int correctly")
        func testPriceTextConversion() {
            let vm = GoalViewModel()
            vm.priceText = "15000"
            
            #expect(vm.priceText == "15000")
        }
        
        @MainActor
        @Test("SaveGoal stores data correctly when valid")
        func testSaveGoalSuccess() {
            let vm = GoalViewModel()
            let mockContext = MockModelContext()
            
            // Simulasi input
            vm.goalName = "Buy Bike"
            vm.priceText = "2000000"
            vm.amountText = "50000"
            vm.selectedDays = ["Mon", "Wed", "Fri"]
            vm.selectedImage = UIImage(systemName: "bicycle")
            
            // Jalankan fungsi
            vm.saveGoal(context: mockContext)
            
            // Cek hasil
            #expect(mockContext.didInsert)
            #expect(mockContext.didSave)
            #expect(mockContext.insertedGoals.first?.name == "Buy Bike")
        }
    }
    
    @Suite("Negative Cases")
    struct GoalViewModelNegativeTests {
        @MainActor
        @Test("Step 1 modal invalid when image missing")
        func testStep1InvalidNoImage() {
            let vm = GoalViewModel()
            vm.goalName = "Mainan"
            vm.priceText = "50000"
            
            #expect(vm.isStep1Valid == false)
        }
        
        @MainActor
        @Test("Step 2 modal invalid when amount is 0")
        func testStep2InvalidZeroAmount() {
            let vm = GoalViewModel()
            vm.selectedDays = ["Mon", "Wed", "Sat"]
            vm.amountText = "0"
            
            #expect(vm.isStep2Valid == false)
        }
        
        @MainActor
        @Test("Save goal should not insert when data is incomplete")
        func testSaveGoal_FailIncompleteData() throws {
            let vm = GoalViewModel()
            vm.goalName = "" // kosong
            vm.priceText = "100000"
            vm.amountText = "50000"
            vm.selectedDays = ["Friday"]
            vm.selectedImage = UIImage(systemName: "photo")
            
            let mockContext = MockModelContext()
            vm.saveGoal(context: mockContext)
            
            #expect(mockContext.didInsert == false)
            #expect(mockContext.didSave == false)
        }
    }

}
