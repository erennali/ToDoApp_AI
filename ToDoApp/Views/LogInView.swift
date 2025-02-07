//
//  LogInView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct LogInView: View {
    
//    @State var email = ""
//    @State var password = ""
    
    @StateObject var viewModel = LogInViewViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                //Header
                HeaderView()
                //Form
                Form {
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundStyle(.red)
                    }
                    TextField("E Mail Adresiniz", text: $viewModel.email)
                        .focused($focusedField, equals: .email)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    SecureField("Şifreniz", text: $viewModel.password)
                        .focused($focusedField, equals: .password)
                }
                .frame(height: 200)
                
                BigButton(title: "Giriş Yap", action: viewModel.login)
                
                //Footer
                
                VStack {
                    Text("Hesabınız yok mu?")
                    NavigationLink("Yeni Hesap Oluştur", destination: RegisterView())
                }
                .padding(.bottom , 100 )
                
            }
            .onTapGesture {
                focusedField = nil // Klavyeyi kapat
            }
        }
    }
}

#Preview {
    LogInView()
}
