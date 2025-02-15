//
//  AIView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import SwiftUI

struct AIView: View {
    
    @State private var inputText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case textField
    }
    
    let aiService = AIService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat mesajları
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                
                // Alt kısım - mesaj gönderme alanı
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("Java dili öğrenmek istiyorum ", text: $inputText, axis: .vertical)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                            .focused($focusedField, equals: .textField)
                        
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(uiColor: .systemBackground))
            }
            .navigationTitle("Ne öğreneceksiniz?")
            .background(Color(uiColor: .systemGroupedBackground))
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil // Klavyeyi kapat
            }
        }
        
        
    }
    
    
    private func sendMessage() {
        let userMessage = ChatMessage(content: inputText, isUser: true, timestamp: Date())
        messages.append(userMessage)
        let userInput = inputText
        inputText = ""
        
        Task {
            isLoading = true
            let response = await aiService.getAIResponse(prompt: userInput)
            
            // Gelen yanıtı paragraflara bölelim
            let paragraphs = response.split(separator: "\n").map { String($0) }
            
            // Her paragrafı tek tek ekleyelim
               for paragraph in paragraphs {
                   // Paragrafın başındaki ve sonundaki boşlukları temizleyelim
                   let cleanedParagraph = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
                   
                   if !cleanedParagraph.isEmpty {
                       let aiMessage = ChatMessage(content: cleanedParagraph, isUser: false, timestamp: Date())
                       messages.append(aiMessage)
                   }
               }
               
               isLoading = false
           }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
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
                        //To do eklemeye yönlendirecek
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
    NavigationView {
        AIView()
    }
}
