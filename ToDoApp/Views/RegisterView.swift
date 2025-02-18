//
//  RegisterView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewViewModel()
    @FocusState private var focusedField: AuthField?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            AuthBackgroundView()
            
            ScrollView {
                VStack(spacing: 25) {
                    HeaderView()
                        .padding(.bottom, 20)
                    
                    // Register Form
                    AuthFormCard(
                        title: "Kayıt Formu",
                        errorMessage: viewModel.errorMessage
                    ) {
                        VStack(spacing: 15) {
                            // Name Field
                            AuthInputField(
                                icon: "person.fill",
                                placeholder: "Kullanıcı Adınız",
                                text: $viewModel.name,
                                field: .name,
                                focusedField: $focusedField
                            )
                            
                            // Email Field
                            AuthInputField(
                                icon: "envelope.fill",
                                placeholder: "E-Postanız",
                                text: $viewModel.email,
                                field: .email,
                                focusedField: $focusedField
                            )
                            
                            // Password Field
                            AuthInputField(
                                icon: "lock.fill",
                                placeholder: "Şifreniz",
                                text: $viewModel.password,
                                field: .password,
                                isSecure: true,
                                focusedField: $focusedField
                            )
                            
                            // Register Button
                            AuthButton(
                                title: "Kayıt Ol",
                                icon: "person.badge.plus.fill",
                                action: viewModel.register,
                                isLoading: viewModel.isLoading
                            )
                        }
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Yeni Hesap")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            focusedField = nil
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
