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
        print("Firebase Error Code: \(err.code)")
        print("Firebase Error Domain: \(err.domain)")
        print("Firebase Error Description: \(err.localizedDescription)")
        
        if let errCode = AuthErrorCode(rawValue: err.code) {
            switch errCode {
            case .wrongPassword:
                return "Girdiğiniz şifre yanlış! Lütfen şifrenizi kontrol edip tekrar deneyin. Şifrenizi unuttuysanız 'Şifremi Unuttum' seçeneğini kullanabilirsiniz."
            case .invalidEmail:
                return "Girdiğiniz e-posta adresi geçersiz! Lütfen doğru formatta bir e-posta adresi girdiğinizden emin olun."
            case .userNotFound:
                return "Bu e-posta adresiyle kayıtlı bir hesap bulunamadı! Eğer yeni bir kullanıcıysanız, lütfen önce kayıt olun."
            case .userDisabled:
                return "Hesabınız güvenlik nedeniyle devre dışı bırakılmış! Lütfen destek ekibiyle iletişime geçin."
            case .tooManyRequests:
                return "Çok fazla başarısız giriş denemesi yaptınız. Güvenliğiniz için lütfen bir süre bekleyip tekrar deneyin."
            case .networkError:
                return "İnternet bağlantınızda bir sorun var! Lütfen bağlantınızı kontrol edip tekrar deneyin."
            case .invalidCredential:
                return "Girdiğiniz şifre yanlış! Lütfen şifrenizi kontrol edip tekrar deneyin."
            default:
                return "Giriş yapılırken bir hata oluştu: \(err.localizedDescription)"
            }
        }
        
        // Eğer AuthErrorCode'a dönüştürülemezse, error message'a göre kontrol edelim
        let errorMessage = err.localizedDescription.lowercased()
        if errorMessage.contains("credential is malformed") || errorMessage.contains("wrong password") {
            return "Girdiğiniz şifre yanlış! Lütfen şifrenizi kontrol edip tekrar deneyin."
        }
        
        return "Giriş yapılırken bir hata oluştu. Lütfen bilgilerinizi kontrol edip tekrar deneyin."
    }
}
