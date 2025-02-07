//
//  ProfileView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewViewModel()
    
    init () {
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let user = viewModel.user {
                    profile(user:user)
                }else {
                    Text("Profil yükleniyor...")
                }
                
                
                //LogOut
                BigButton(title: "Çıkış Yap") {
                    viewModel.logOut()
                }
                
                
            }
            .navigationTitle("Profil")
        }
        .onAppear{
             viewModel.fetchUser()
        }
    }
    
    @ViewBuilder
    func profile(user: User) -> some View {
        
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.gray)
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("İsim: ")
                    Text(user.name)
                }
                HStack {
                    Text("Email: ")
                    Text(user.email)
                }
                HStack {
                    Text("Kayıt Tarihi: ")
                    Text("\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .shortened))")
                }
    
            }
            
        }
        
        
    }
}

#Preview {
    ProfileView()
}
