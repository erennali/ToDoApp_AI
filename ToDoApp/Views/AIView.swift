//
//  AIView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import SwiftUI

struct AIView: View {
    
    @State private var inputText: String = ""
    @State private var responseText: String = ""
    @State private var isLoading: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case textField
    }
    
    let aiService = AIService()
    
    var body: some View {
        VStack(spacing: 20) {
            // Soru giriş alanı
            TextField("Sorunuzu yazın...", text: $inputText, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled()
                .padding(.horizontal)
                .focused($focusedField, equals: .textField)
            
            // Gönder butonu
            AsyncButton {
                isLoading = true
                responseText = await aiService.getAIResponse(prompt: inputText)
                isLoading = false
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    }
                    Text(isLoading ? "Yanıt bekleniyor..." : "AI'ya Sor")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isLoading ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            // Yanıt alanı
            if !responseText.isEmpty {
                ScrollView {
                    Text(responseText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .padding(.vertical)
        .navigationTitle("AI Asistan")
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil // Klavyeyi kapat
        }
    }
}

#Preview {
    NavigationView {
        AIView()
    }
}
