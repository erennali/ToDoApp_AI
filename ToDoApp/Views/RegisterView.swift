//
//  RegisterView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct RegisterView: View {
    
//    @State var name = ""
//    @State var email = ""
//    @State var password = ""
    
    @StateObject var viewModel = RegisterViewViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, password
    }
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                HeaderView()
                //Register
                
                Form {
                    Section(header: Text("Kayıt Formu")) {
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundStyle(.red)
                        }
                        
                        TextField("Kullanıcı Adınız", text: $viewModel.name)
                            .focused($focusedField, equals: .name)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        TextField("E-Postanız", text: $viewModel.email)
                            .focused($focusedField, equals: .email)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        SecureField("Şifreniz", text: $viewModel.password)
                            .focused($focusedField, equals: .password)
                    }
                    
                }.frame(height: 250)
                
                BigButton(title: "Kayıt Ol", action: {viewModel.register() })
                Spacer()
                
            }
            .onTapGesture {
                focusedField = nil // Klavyeyi kapat
            }
        }
    }
}

#Preview {
    RegisterView()
}
