//
//  ContentView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
//        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
//            accountView
//        } else {
//            LogInView()
//        }
        accountView
            
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
