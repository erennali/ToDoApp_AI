//
//  ToDoAppApp.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct ToDoAppApp: App {
    
    @State var showPreviewPage = true
    @StateObject var viewModel = MainViewViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if showPreviewPage {
                WelcomeView()
                    .onAppear {
                        // Welcome ekranı gösterilirken Firebase'den kullanıcı durumunu al
                        if let user = Auth.auth().currentUser {
                            viewModel.currentUserId = user.uid
                            viewModel.isSignedIn = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showPreviewPage = false
                        }
                    }
            } else {
                MainView(viewModel: viewModel)
            }
        }
    }
}
