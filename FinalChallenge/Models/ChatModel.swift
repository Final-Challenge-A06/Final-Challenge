//
//  ChatModel.swift
//  FinalChallenge
//
//  Created by Ahmad Zuhal Zhafran on 12/11/25.
//

import Foundation
import Combine

@MainActor
final class ChatModel: ObservableObject {
    @Published var messages: [String] = [
        "Hello, I'm Billo",
        "Before we start let’s read the tutorial together"
    ]
    @Published var currentIndex: Int = 0

    var currentText: String {
        guard messages.indices.contains(currentIndex) else { return "" }
        return messages[currentIndex]
    }
}
