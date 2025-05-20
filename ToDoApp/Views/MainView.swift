//
//  ContentView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Group {
            if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
                accountView
            } else {
                LogInView()
            }
        }
        .onAppear {
            // MainView gösterildiğinde kullanıcı durumunu tekrar kontrol et
            // Bu durumda, splash ekranında zaten kullanıcı verileri yüklenmiş olmalı
            if let user = Auth.auth().currentUser, viewModel.currentUserId.isEmpty {
                viewModel.currentUserId = user.uid
                viewModel.isSignedIn = true
            }
        }
    }
    
    @ViewBuilder
    var accountView: some View {
        if horizontalSizeClass == .regular {
            // iPad için özel layout
            NavigationSplitView {
                List {
                    NavigationLink {
                        ToDoListView(userId: viewModel.currentUserId)
                    } label: {
                        Label("Görevler", systemImage: "house")
                    }
                    
                    NavigationLink {
                        AIView()
                    } label: {
                        Label("AI a Sor", systemImage: "brain")
                    }
                    
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Label("Profil", systemImage: "person.circle")
                    }
                }
                .listStyle(.sidebar)
            } detail: {
                ToDoListView(userId: viewModel.currentUserId)
            }
        } else {
            // iPhone için mevcut TabView
            TabView {
                ToDoListView(userId: viewModel.currentUserId)
                    .tabItem {
                        Label("Görevler", systemImage: "house")
                    }
                AIView()
                    .tabItem {
                        Label("AI a Sor", systemImage: "brain")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person.circle")
                    }
            }
        }
    }
}

#Preview {
    MainView(viewModel: MainViewViewModel())
}
