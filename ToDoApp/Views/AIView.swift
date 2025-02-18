//
//  AIView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import SwiftUI

struct AIView: View {
    // MARK: - Properties
    @StateObject private var viewModel: AIViewModel
    @FocusState private var focusedField: Field?
    
    // MARK: - Init
    init(viewModel: AIViewModel = AIViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Field Enum
    enum Field {
        case textField
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                chatMessagesView
                messageInputView
            }
            .navigationTitle("Ne öğreneceksiniz?")
            .background(Color(uiColor: .systemGroupedBackground))
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .sheet(isPresented: $viewModel.showNewItem) {
                NewItemView(
                    newItemPresented: $viewModel.showNewItem,
                    alinanMetin: viewModel.getCleanedSelectedMessage()
                )
            }
        }
    }
    
    // MARK: - Subviews
    private var chatMessagesView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.messages) { message in
                    MessageBubbleView(
                        message: message,
                        viewModel: MessageBubbleViewModel(aiViewModel: viewModel)
                    )
                }
            }
            .padding()
        }
    }
    
    private var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                TextField("Java dili öğrenmek istiyorum", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                    .focused($focusedField, equals: .textField)
                
                Button {
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    AIView()
}
