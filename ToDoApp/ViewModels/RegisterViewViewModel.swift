//
//  RegisterViewViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    init() {}
    
    func register() {
        guard validate() else {
            showAlert = true
            alertTitle = "Hata"
            alertMessage = errorMessage
            return
        }
        
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = self?.handleFirebaseError(error) ?? "Kayıt olurken bir hata oluştu."
                    self?.showAlert = true
                    self?.alertTitle = "Hata"
                    self?.alertMessage = self?.errorMessage ?? ""
                    return
                }
                
                guard let userId = result?.user.uid else {
                    self?.errorMessage = "Kullanıcı oluşturulamadı."
                    self?.showAlert = true
                    self?.alertTitle = "Hata"
                    self?.alertMessage = self?.errorMessage ?? ""
                    return
                }
                
                self?.insertUserRecord(id: userId)
            }
        }
    }
    
    private func insertUserRecord(id: String) {
        let newUser = User(id: id, name: name, email: email, joined: Date().timeIntervalSince1970)
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(id)
            .setData(newUser.asDictionary()) { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Kullanıcı bilgileri kaydedilemedi: \(error.localizedDescription)"
                        self?.showAlert = true
                        self?.alertTitle = "Hata"
                        self?.alertMessage = self?.errorMessage ?? ""
                    }
                }
            }
    }
    
    private func validate() -> Bool {
        errorMessage = ""
        
        // Boş alan kontrolü
        if name.trimmingCharacters(in: .whitespaces).isEmpty ||
           email.trimmingCharacters(in: .whitespaces).isEmpty ||
           password.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Lütfen tüm alanları doldurunuz."
            return false
        }
        
        // İsim uzunluğu kontrolü
        if name.count < 3 {
            errorMessage = "İsim en az 3 karakter olmalıdır."
            return false
        }
        
        // Email formatı kontrolü
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if !emailPred.evaluate(with: email) {
            errorMessage = "Geçerli bir e-posta adresi giriniz."
            return false
        }
        
        // Şifre kontrolü
        if password.count < 6 {
            errorMessage = "Şifreniz en az 6 karakterden oluşmalıdır."
            return false
        }
        
        // Şifre güvenliği kontrolü
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$"
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        if !passwordPred.evaluate(with: password) {
            errorMessage = "Şifreniz en az bir harf ve bir rakam içermelidir."
            return false
        }
        
        return true
    }
    
    private func handleFirebaseError(_ error: Error) -> String {
        let err = error as NSError
        switch err.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Bu e-posta adresi zaten kullanımda!"
        case AuthErrorCode.invalidEmail.rawValue:
            return "Geçersiz e-posta adresi!"
        case AuthErrorCode.weakPassword.rawValue:
            return "Şifreniz çok zayıf. Lütfen daha güçlü bir şifre seçin!"
        case AuthErrorCode.networkError.rawValue:
            return "İnternet bağlantınızı kontrol edin!"
        default:
            return "Kayıt olurken bir hata oluştu: \(error.localizedDescription)"
        }
    }
}
