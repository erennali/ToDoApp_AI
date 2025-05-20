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
            
            // Request permission for notifications
            OneSignal.Notifications.requestPermission({ accepted in
                print("User accepted notifications: \(accepted)")
            }, fallbackToSettings: true)
        } else {
            print("⚠️ OneSignal App ID not found in environment")
        }
        
        // Initialize notification manager
        _ = NotificationManager.shared
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(tokenString)")
    }
}

@main
struct ToDoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var showPreviewPage = true
    @StateObject var viewModel = MainViewViewModel()
    
    init() {
        FirebaseApp.configure()
        
        // App başlatılırken kullanıcı durumunu önceden hazırla
        preloadAuthenticationState()
    }
    
    // Kullanıcı kimlik doğrulama durumunu önceden yükle
    private func preloadAuthenticationState() {
        if let user = Auth.auth().currentUser {
            print("App launch: Found existing user \(user.uid)")
            
            // Kullanıcının verilerini ProfileViewViewModel aracılığıyla önceden yükle
            _ = ProfileViewViewModel.shared
        } else {
            print("App launch: No user logged in")
        }
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
                            
                            // ProfileViewViewModel'i önceden başlat
                            let _ = ProfileViewViewModel.shared
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
