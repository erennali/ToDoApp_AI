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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
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
                // Arka plan gradyanı
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Quota indicator
                    HStack {
                        Spacer()
                        Text("Kalan AI Mesaj Hakkı: \(viewModel.aiMessageQuota)")
                            .font(.system(size: horizontalSizeClass == .regular ? 18 : 16))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, horizontalSizeClass == .regular ? 12 : 8)
                    }
                    
                    chatMessagesView
                    messageInputView
                }
            }
            .navigationTitle("Ne öğreneceksiniz?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            
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
        .navigationViewStyle(horizontalSizeClass == .regular ? .stack : .stack)
    }
    
    // MARK: - Subviews
    private var chatMessagesView: some View {
        ScrollView {
            LazyVStack(spacing: horizontalSizeClass == .regular ? 16 : 12) {
                ForEach(viewModel.messages) { message in
                    MessageBubbleView(
                        message: message,
                        viewModel: MessageBubbleViewModel(aiViewModel: viewModel)
                    )
                    .padding(.horizontal, horizontalSizeClass == .regular ? 20 : 0)
                }
            }
            .padding()
        }
        .background(Color.clear)
    }
    
    private var messageInputView: some View {
        VStack(spacing: 0) {
            HStack(spacing: horizontalSizeClass == .regular ? 16 : 12) {
                TextField("Java dili öğrenmek istiyorum", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.vertical, horizontalSizeClass == .regular ? 12 : 8)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .focused($focusedField, equals: .textField)
                    .foregroundColor(.white)
                    .tint(.white)
                    .font(.system(size: horizontalSizeClass == .regular ? 18 : 16))
                
                Button {
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: horizontalSizeClass == .regular ? 40 : 32))
                        .foregroundColor(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .white)
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal, horizontalSizeClass == .regular ? 24 : 16)
            .padding(.vertical, horizontalSizeClass == .regular ? 12 : 8)
        }
        .background(Color.black.opacity(0.2))
    }
}

#Preview {
    Group {
        AIView()
            .environment(\.horizontalSizeClass, .compact)
        AIView()
            .environment(\.horizontalSizeClass, .regular)
    }
}
