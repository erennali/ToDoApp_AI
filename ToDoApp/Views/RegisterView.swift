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
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        TextField("E-Postanız", text: $viewModel.email)
                            .autocorrectionDisabled()
                        //oto doldurtmama
                            .autocapitalization(.none)
                        //baş harfi büyük yaptırmama otomatik
                        SecureField("Şifreniz", text: $viewModel.password)
                    }
                    
                }.frame(height: 250)
                
                BigButton(title: "Kayıt Ol", action: {viewModel.register() })
                Spacer()
                
               
                
            }
        }
    }
}

#Preview {
    RegisterView()
}
