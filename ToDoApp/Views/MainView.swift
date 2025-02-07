//
//  ContentView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var viewModel: MainViewViewModel
    
    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            accountView
        } else {
            LogInView()
        }
    }
    
    @ViewBuilder
    var accountView: some View {
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

#Preview {
    MainView(viewModel: MainViewViewModel())
}
