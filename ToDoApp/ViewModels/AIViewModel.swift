//
//  AIViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import Foundation

class AIViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var inputText: String = ""
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var selectedMessage: String = ""
    @Published var showNewItem: Bool = false
    
    // MARK: - Private Properties
    private let aiService: AIService
    
    // MARK: - Init
    init(aiService: AIService = AIService()) {
        self.aiService = aiService
    }
    
    // MARK: - Public Methods
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(content: inputText, isUser: true, timestamp: Date())
        messages.append(userMessage)
        let userInput = inputText
        inputText = ""
        
        Task {
            await sendToAI(prompt: userInput)
        }
    }
    
    func getCleanedSelectedMessage() -> String {
        return selectedMessage
            .replacingOccurrences(of: "Adım 1: ", with: "")
            .replacingOccurrences(of: "Adım 2: ", with: "")
            .replacingOccurrences(of: "Adım 3: ", with: "")
            .replacingOccurrences(of: "Adım 4: ", with: "")
            .replacingOccurrences(of: "Adım 5: ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Private Methods
    @MainActor
    private func sendToAI(prompt: String) async {
        isLoading = true
        let response = await aiService.getAIResponse(prompt: prompt)
        
        // Split response into paragraphs
        let paragraphs = response.split(separator: "\n").map { String($0) }
        
        // Add each paragraph as a separate message
        for paragraph in paragraphs {
            let cleanedParagraph = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !cleanedParagraph.isEmpty {
                let aiMessage = ChatMessage(content: cleanedParagraph, isUser: false, timestamp: Date())
                messages.append(aiMessage)
            }
        }
        
        isLoading = false
    }
} 