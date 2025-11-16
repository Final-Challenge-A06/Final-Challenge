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
        "Before we start let's read the tutorial together",
    ]
    @Published var currentIndex: Int = 0
    @Published var displayedCharacterCount: Int = 0
    @Published var isTyping: Bool = false
    
    private var typingTask: Task<Void, Never>?
    private let typingSpeed: TimeInterval = 0.05 // Kecepatan typing (detik per karakter)

    var currentText: String {
        guard messages.indices.contains(currentIndex) else { return "" }
        return messages[currentIndex]
    }
    
    var typedText: String {
        guard messages.indices.contains(currentIndex) else { return "" }
        let fullText = messages[currentIndex]
        let endIndex = fullText.index(fullText.startIndex, offsetBy: min(displayedCharacterCount, fullText.count))
        return String(fullText[..<endIndex])
    }
    
    // Helper untuk menampilkan satu pesan dinamis
    func showSingle(_ text: String) {
        messages = [text]
        currentIndex = 0
        startTypingAnimation()
    }
    
    func startTypingAnimation() {
        typingTask?.cancel()
        displayedCharacterCount = 0
        isTyping = true
        
        let targetCount = currentText.count
        
        typingTask = Task {
            for i in 1...targetCount {
                try? await Task.sleep(for: .seconds(typingSpeed))
                if Task.isCancelled { break }
                displayedCharacterCount = i
            }
            isTyping = false
        }
    }
    
    func skipTypingAnimation() {
        typingTask?.cancel()
        displayedCharacterCount = currentText.count
        isTyping = false
    }
}
