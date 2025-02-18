//
//  LogInViewViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import FirebaseAuth
import Foundation

class LogInViewViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    init() {
        
    }
    
    func login() {
        guard validate() else {
            showAlert = true
            alertTitle = "Hata"
            alertMessage = errorMessage
            return
        }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = self?.handleFirebaseError(error) ?? "Giriş yapılırken bir hata oluştu."
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
        if email.trimmingCharacters(in: .whitespaces).isEmpty || 
           password.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Lütfen tüm alanları doldurun!"
            return false
        }
        
        // Email formatı kontrolü
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if !emailPred.evaluate(with: email) {
            errorMessage = "Geçerli bir e-posta adresi giriniz!"
            return false
        }
        
        // Şifre uzunluğu kontrolü
        if password.count < 6 {
            errorMessage = "Şifre en az 6 karakter olmalıdır!"
            return false
        }
        
        return true
    }
    
    private func handleFirebaseError(_ error: Error) -> String {
        let err = error as NSError
        switch err.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "E-posta veya şifre hatalı!"
        case AuthErrorCode.invalidEmail.rawValue:
            return "Geçersiz e-posta adresi!"
        case AuthErrorCode.userNotFound.rawValue:
            return "Kullanıcı bulunamadı!"
        case AuthErrorCode.userDisabled.rawValue:
            return "Hesabınız devre dışı bırakılmış!"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin!"
        case AuthErrorCode.networkError.rawValue:
            return "İnternet bağlantınızı kontrol edin!"
        default:
            return "Giriş yapılırken bir hata oluştu: \(error.localizedDescription)"
        }
    }
}
