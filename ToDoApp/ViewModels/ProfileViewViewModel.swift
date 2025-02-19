//
//  ProfileViewViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//
import FirebaseAuth
import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

class ProfileViewViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isLoading = true
    @Published var profileImage: UIImage?
    @Published var isImageUploading = false
    
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    static let shared = ProfileViewViewModel()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let userId = user?.uid {
                self?.fetchUserData(userId: userId)
            } else {
                DispatchQueue.main.async {
                    self?.clearUserData()
                }
            }
        }
    }
    
    private func clearUserData() {
        user = nil
        profileImage = nil
        isLoading = false
    }
    
    private func fetchUserData(userId: String) {
        isLoading = true
        
        db.collection("users")
            .document(userId)
            .getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    self.handleError()
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("No user data found")
                    self.handleError()
                    return
                }
                
                DispatchQueue.main.async {
                    self.user = User(
                        id: data["id"] as? String ?? "",
                        name: data["name"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        joined: data["joined"] as? TimeInterval ?? 0,
                        aiMessageQuota: data["aiMessageQuota"] as? Int ?? 0
                    )
                    
                    // Profil fotoğrafını hemen yükle
                    self.loadProfileImage(userId: userId)
                }
            }
    }
    
    private func handleError() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.user = nil
            self.profileImage = nil
        }
    }
    
    private func loadProfileImage(userId: String) {
        let profileImageRef = storage.child("profile_images/\(userId).jpg")
        
        profileImageRef.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                } else if let data = data, let image = UIImage(data: data) {
                    self?.profileImage = image
                }
                self?.isLoading = false
            }
        }
    }
    
    func uploadProfileImage(_ image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found")
            return
        }
        
        isImageUploading = true
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Could not compress image")
            isImageUploading = false
            return
        }
        
        let profileImageRef = storage.child("profile_images/\(userId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: metadata) { [weak self] _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isImageUploading = false
                }
                return
            }
            
            profileImageRef.downloadURL { [weak self] url, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    } else if let url = url {
                        self?.updateProfileImageURL(url.absoluteString)
                        self?.profileImage = image
                    }
                    self?.isImageUploading = false
                }
            }
        }
    }
    
    private func updateProfileImageURL(_ urlString: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).updateData([
            "profileImageURL": urlString
        ]) { error in
            if let error = error {
                print("Error updating profile image URL: \(error.localizedDescription)")
            }
        }
    }
    
    func logOut() {
        do {
            // Clear local user data first
            clearUserData()
            
            // Sign out from Firebase Auth
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}

