//
//  ToDoAppApp.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UserNotifications
import OneSignalFramework

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
       // Remove this method to stop OneSignal Debugging
       OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        
       // OneSignal initialization
       if let oneSignalAppId = EnvironmentManager.oneSignalAppId {
           OneSignal.initialize(oneSignalAppId, withLaunchOptions: launchOptions)
           
           // requestPermission will show the native iOS notification permission prompt.
           OneSignal.Notifications.requestPermission({ accepted in
               print("User accepted notifications: \(accepted)")
           }, fallbackToSettings: true)
       } else {
           print("⚠️ OneSignal App ID not found in environment")
       }

       return true
    }
}

@main
struct ToDoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var showPreviewPage = true
    @StateObject var viewModel = MainViewViewModel()
    
    init() {
        FirebaseApp.configure()
        // Request notification permissions
        NotificationManager.shared.requestAuthorization()
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
