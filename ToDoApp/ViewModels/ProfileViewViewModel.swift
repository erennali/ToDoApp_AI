//
//  ProfileViewViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//
import FirebaseAuth
import Foundation
import FirebaseFirestore

class ProfileViewViewModel : ObservableObject {
    @Published var user : User? = nil
    @Published var isLoading = true
    
    init() {
        fetchUser()
    }
    
    func fetchUser() {
        isLoading = true
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching user: \(error)")
                        self?.isLoading = false
                        return
                    }
                    
                    guard let data = snapshot?.data() else {
                        print("No user data found")
                        self?.isLoading = false
                        return
                    }
                    
                    self?.user = User(
                        id: data["id"] as? String ?? "",
                        name: data["name"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        joined: data["joined"] as? TimeInterval ?? 0,
                        aiMessageQuota: data["aiMessageQuota"] as? Int ?? 0
                    )
                    self?.isLoading = false
                }
            }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
}
