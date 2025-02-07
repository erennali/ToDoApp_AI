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
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
                self?.isSignedIn = user != nil
            }
        }
    }
    
    public var isUserSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
