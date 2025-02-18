//
//  MessageBubbleViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import Foundation

class MessageBubbleViewModel: ObservableObject {
    // MARK: - Properties
    private let aiViewModel: AIViewModel
    
    // MARK: - Init
    init(aiViewModel: AIViewModel) {
        self.aiViewModel = aiViewModel
    }
    
    // MARK: - Methods
    func addNewItem(with content: String) {
        aiViewModel.selectedMessage = content
        aiViewModel.showNewItem = true
    }
} 