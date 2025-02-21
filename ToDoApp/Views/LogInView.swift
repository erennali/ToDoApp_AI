//
//  LogInView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct LogInView: View {
    @StateObject var viewModel = LogInViewViewModel()
    @FocusState private var focusedField: AuthField?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                AuthBackgroundView()
                
                ScrollView {
                    VStack(spacing: 25) {
                        HeaderView()
                            .padding(.bottom, 20)
                        
                        // Login Form
                        AuthFormCard(
                            title: "Giriş",
                            errorMessage: viewModel.errorMessage
                        ) {
                            VStack(spacing: 15) {
                                // Email Field
                                AuthInputField(
                                    icon: "envelope.fill",
                                    placeholder: "E Mail Adresiniz",
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
                                
                                // Login Button
                                AuthButton(
                                    title: "Giriş Yap",
                                    icon: "arrow.right.circle.fill",
                                    action: viewModel.login,
                                    isLoading: viewModel.isLoading
                                )
                                
                                // Password Reset Button
                                Button(action: viewModel.resetPassword) {
                                    Text("Şifremi Unuttum")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .disabled(viewModel.isLoading)
                                .padding(.top, -5)
                                
                                // Demo Login Button
                                Button(action: {
                                    viewModel.demoLogin()
                                }) {
                                    HStack {
                                        Image(systemName: "person.fill.questionmark")
                                        Text("Demo Hesabı ile Giriş")
                                    }
                                    .foregroundColor(.orange)
                                    .font(.system(size: 14, weight: .medium))
                                }
                                .disabled(viewModel.isLoading)
                            }
                        }
                        
                        // Register Link
                        VStack(spacing: 10) {
                            Text("Hesabınız yok mu?")
                                .foregroundColor(.gray)
                            NavigationLink {
                                RegisterView()
                            } label: {
                                Text("Yeni Hesap Oluştur")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationBarHidden(true)
            .onTapGesture {
                focusedField = nil
            }
            .alert(isPresented: $viewModel.showAlert) {
                if viewModel.alertTitle == "E-posta Doğrulaması Gerekli" {
                    Alert(
                        title: Text(viewModel.alertTitle),
                        message: Text(viewModel.alertMessage),
                        primaryButton: .default(Text("Tamam")),
                        secondaryButton: .default(Text("Yeni Doğrulama E-postası Gönder"), 
                                                action: viewModel.resendVerificationEmail)
                    )
                } else {
                    Alert(
                        title: Text(viewModel.alertTitle),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("Tamam"))
                    )
                }
            }
        }
    }
}

#Preview {
    LogInView()
}
