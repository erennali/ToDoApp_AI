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
                    
                    // Profil fotoğrafını yükle
                    self?.fetchProfileImage()
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
        
        // Resmi sıkıştır
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Could not compress image")
            isImageUploading = false
            return
        }
        
        let profileImageRef = storage.child("profile_images/\(userId).jpg")
        
        // Metadata ekle
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: metadata) { [weak self] metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isImageUploading = false
                }
                return
            }
            
            // Yükleme başarılı, URL'yi al
            profileImageRef.downloadURL { url, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        self?.isImageUploading = false
                        return
                    }
                    
                    // Firestore'da profil fotoğrafı URL'sini güncelle
                    if let url = url {
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
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "profileImageURL": urlString
        ]) { error in
            if let error = error {
                print("Error updating profile image URL: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchProfileImage() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found for fetching image")
            return
        }
        
        let profileImageRef = storage.child("profile_images/\(userId).jpg")
        
        profileImageRef.getData(maxSize: 5 * 1024 * 1024) { [weak self] data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.profileImage = image
                }
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
