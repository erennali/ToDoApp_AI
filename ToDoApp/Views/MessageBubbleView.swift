//
//  MessageBubbleView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import SwiftUI

struct MessageBubbleView: View {
    // MARK: - Properties
    let message: ChatMessage
    @StateObject var viewModel: MessageBubbleViewModel
    
    // MARK: - Init
    init(message: ChatMessage, viewModel: MessageBubbleViewModel) {
        self.message = message
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            HStack {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? Color.blue : Color.gray)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                    .shadow(color: Color(.systemGray4), radius: 1)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
                
                if(!message.isUser && message.content.starts(with: "Adım")){
                    Button {
                        viewModel.addNewItem(with: message.content)
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20))
                    }
                }
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

#Preview {
    MessageBubbleView(
        message: ChatMessage(content: "Test Message", isUser: false, timestamp: Date()),
        viewModel: MessageBubbleViewModel(aiViewModel: AIViewModel())
    )
} 