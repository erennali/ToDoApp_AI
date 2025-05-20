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
    
    // Veri yükleme durumunu izlemek için
    private var isFetchingData = false
    
    static let shared = ProfileViewViewModel()
    
    init() {
        setupAuthStateListener()
        
        // İlk başlatıldığında, eğer kullanıcı varsa hemen verileri yüklemeye başla
        if let userId = Auth.auth().currentUser?.uid {
            fetchUserData(userId: userId)
        }
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
        // Eğer halihazırda veri yükleme işlemi yapılıyorsa, tekrar başlatma
        guard !isFetchingData else {
            print("User data fetch already in progress for \(userId)")
            return
        }
        
        isLoading = true
        isFetchingData = true
        print("Fetching user data for \(userId)...")
        
        let userDocument = db.collection("users").document(userId)
        let profileImageRef = storage.child("profile_images/\(userId).jpg")
        
        // Kullanıcı verisi ve profil fotoğrafını paralel olarak yükle
        let dispatchGroup = DispatchGroup()
        
        // Kullanıcı verileri yükleme
        dispatchGroup.enter()
        userDocument.getDocument { [weak self] snapshot, error in
            defer { dispatchGroup.leave() }
            
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                self?.handleError()
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No user data found")
                self?.handleError()
                return
            }
            
            DispatchQueue.main.async {
                self?.user = User(
                    id: data["id"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    joined: data["joined"] as? TimeInterval ?? 0,
                    aiMessageQuota: data["aiMessageQuota"] as? Int ?? 0
                )
            }
        }
        
        // Profil fotoğrafı yükleme
        dispatchGroup.enter()
        profileImageRef.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
            defer { dispatchGroup.leave() }
            
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
            } else if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.profileImage = image
                }
            }
        }
        
        // Tüm veriler yüklendiğinde
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.isFetchingData = false
            print("User data loading completed for \(userId)")
        }
    }
    
    private func handleError() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.isFetchingData = false
            self.user = nil
            self.profileImage = nil
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
    
    func deleteAccount() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found")
            return
        }
        // Firestore'dan kullanıcı verilerini sil
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
                return
            }
            // Firebase Authentication'dan kullanıcıyı sil
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    print("Error deleting user: \(error.localizedDescription)")
                } else {
                    print("User account deleted successfully.")
                    // Kullanıcı verilerini temizle
                    self.clearUserData()
                }
            }
        }
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}

