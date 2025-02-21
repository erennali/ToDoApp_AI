//
//  MainViewViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import Foundation
import FirebaseAuth

class MainViewViewModel : ObservableObject {
    @Published var currentUserId: String = ""
    @Published var isSignedIn: Bool = false
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        validateCurrentUser()
        setupAuthStateListener()
    }
    
    private func validateCurrentUser() {
        if let currentUser = Auth.auth().currentUser {
            // Kullanıcının hala geçerli olduğunu kontrol et
            currentUser.reload { [weak self] error in
                if let error = error {
                    print("User validation error: \(error.localizedDescription)")
                    // Kullanıcı artık geçerli değil, çıkış yap
                    try? Auth.auth().signOut()
                    DispatchQueue.main.async {
                        self?.currentUserId = ""
                        self?.isSignedIn = false
                    }
                } else {
                    // E-posta doğrulaması kontrolü
                    if !currentUser.isEmailVerified {
                        // E-posta doğrulanmamış, çıkış yap
                        try? Auth.auth().signOut()
                        DispatchQueue.main.async {
                            self?.currentUserId = ""
                            self?.isSignedIn = false
                        }
                        // Yeni doğrulama e-postası gönder
                        currentUser.sendEmailVerification { error in
                            if let error = error {
                                print("Error sending verification email: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        // Kullanıcı hala geçerli ve e-posta doğrulanmış
                        DispatchQueue.main.async {
                            self?.currentUserId = currentUser.uid
                            self?.isSignedIn = true
                        }
                    }
                }
            }
        }
    }
    
    private func setupAuthStateListener() {
        // Remove existing listener if any
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
        
        // Set up new listener
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                // Kullanıcı var, geçerliliğini kontrol et
                user.reload { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Auth state listener error: \(error.localizedDescription)")
                            // Kullanıcı artık geçerli değil
                            self?.currentUserId = ""
                            self?.isSignedIn = false
                            try? Auth.auth().signOut()
                        } else {
                            // Anonim (demo) kullanıcı kontrolü
                            if user.isAnonymous {
                                self?.currentUserId = user.uid
                                self?.isSignedIn = true
                            } else {
                                // Normal kullanıcılar için e-posta doğrulaması kontrolü
                                if !user.isEmailVerified {
                                    // E-posta doğrulanmamış, çıkış yap
                                    try? Auth.auth().signOut()
                                    self?.currentUserId = ""
                                    self?.isSignedIn = false
                                    // Yeni doğrulama e-postası gönder
                                    user.sendEmailVerification { error in
                                        if let error = error {
                                            print("Error sending verification email: \(error.localizedDescription)")
                                        }
                                    }
                                } else {
                                    // Kullanıcı hala geçerli ve e-posta doğrulanmış
                                    self?.currentUserId = user.uid
                                    self?.isSignedIn = true
                                }
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.currentUserId = ""
                    self?.isSignedIn = false
                }
            }
        }
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    public var isUserSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
