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
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.2, blue: 0.45),
                        Color(red: 0.3, green: 0.2, blue: 0.5),
                        Color(red: 0.2, green: 0.3, blue: 0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Quota indicator
                    HStack {
                        Spacer()
                        Text("Kalan AI Mesaj Hakkı: \(viewModel.aiMessageQuota)")
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                    
                    chatMessagesView
                    messageInputView
                }
            }
            .navigationTitle("Ne öğreneceksiniz?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(red: 0.1, green: 0.2, blue: 0.45), for: .navigationBar)
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
            .alert("Mesaj Hakkınız Bitti", isPresented: $viewModel.showQuotaAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text("AI mesaj gönderme hakkınız kalmadı.")
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
        .background(Color.clear)
    }
    
    private var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white)
            HStack(spacing: 12) {
                TextField("Java dili öğrenmek istiyorum", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .focused($focusedField, equals: .textField)
                    .foregroundColor(.white)
                    .tint(.white)
                
                Button {
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .white)
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.black.opacity(0.2))
    }
}

#Preview {
    AIView()
}
