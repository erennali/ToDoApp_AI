//
//  LogInViewViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import FirebaseAuth
import FirebaseFirestore
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
                    return
                }
                
                // E-posta doğrulama kontrolü
                guard let user = result?.user else { return }
                
                if !user.isEmailVerified {
                    // E-posta doğrulanmamış, çıkış yap
                    try? Auth.auth().signOut()
                    
                    DispatchQueue.main.async {
                        self?.errorMessage = "E-posta adresiniz henüz doğrulanmamış. Lütfen e-posta kutunuzu ve spam klasörünüzü kontrol edin.\n\nEğer doğrulama e-postası almadıysanız, yeni bir doğrulama e-postası isteyebilirsiniz."
                        self?.showAlert = true
                        self?.alertTitle = "E-posta Doğrulaması Gerekli"
                        self?.alertMessage = self?.errorMessage ?? ""
                    }
                    return
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
    
    func resendVerificationEmail() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Önce giriş yapmanız gerekiyor."
            showAlert = true
            alertTitle = "Hata"
            alertMessage = errorMessage
            return
        }
        
        // Son doğrulama e-postası gönderme zamanını kontrol et
        let lastEmailSentKey = "lastVerificationEmailSent_\(user.uid)"
        let currentTime = Date().timeIntervalSince1970
        
        if let lastSentTime = UserDefaults.standard.double(forKey: lastEmailSentKey) as Double?,
           currentTime - lastSentTime < 60 { // 60 saniye bekle
            errorMessage = "Lütfen yeni bir doğrulama e-postası göndermek için biraz bekleyin."
            showAlert = true
            alertTitle = "Uyarı"
            alertMessage = errorMessage
            return
        }
        
        user.sendEmailVerification { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    if (error as NSError).code == 17010 { // Çok fazla istek hatası
                        self?.errorMessage = "Çok fazla doğrulama e-postası isteği gönderildi. Lütfen bir süre bekleyip tekrar deneyin."
                    } else {
                        self?.errorMessage = "Doğrulama e-postası gönderilirken bir hata oluştu: \(error.localizedDescription)"
                    }
                    self?.showAlert = true
                    self?.alertTitle = "Hata"
                    self?.alertMessage = self?.errorMessage ?? ""
                } else {
                    // Başarılı gönderim zamanını kaydet
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastEmailSentKey)
                    
                    self?.errorMessage = "Yeni doğrulama e-postası gönderildi. Lütfen e-posta kutunuzu ve spam klasörünüzü kontrol edin."
                    self?.showAlert = true
                    self?.alertTitle = "Başarılı"
                    self?.alertMessage = self?.errorMessage ?? ""
                }
            }
        }
    }
    
    func resetPassword() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Lütfen e-posta adresinizi girin!"
            showAlert = true
            alertTitle = "Hata"
            alertMessage = errorMessage
            return
        }
        
        // Email formatı kontrolü
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if !emailPred.evaluate(with: email) {
            errorMessage = "Geçerli bir e-posta adresi giriniz!"
            showAlert = true
            alertTitle = "Hata"
            alertMessage = errorMessage
            return
        }
        
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Şifre sıfırlama e-postası gönderilirken bir hata oluştu: \(error.localizedDescription)"
                    self?.showAlert = true
                    self?.alertTitle = "Hata"
                    self?.alertMessage = self?.errorMessage ?? ""
                } else {
                    self?.errorMessage = "Şifre sıfırlama e-postası gönderildi. Lütfen e-posta kutunuzu kontrol edin."
                    self?.showAlert = true
                    self?.alertTitle = "Başarılı"
                    self?.alertMessage = self?.errorMessage ?? ""
                }
            }
        }
    }
    
    func demoLogin() {
        isLoading = true
        
        // Demo kullanıcı bilgileri
        let demoEmail = "demo@todoapp.com"
        let demoPassword = "demo123"
        
        Auth.auth().signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Demo giriş yapılırken bir hata oluştu: \(error.localizedDescription)"
                    self?.showAlert = true
                    self?.alertTitle = "Hata"
                    self?.alertMessage = self?.errorMessage ?? ""
                    return
                }
                
                // Demo kullanıcı bilgilerini Firestore'a kaydet
                if let userId = result?.user.uid {
                    let db = Firestore.firestore()
                    let userDocument = db.collection("users").document(userId)
                    
                    let userData: [String: Any] = [
                        "name": "Demo Kullanıcı",
                        "email": demoEmail,
                        "joined": Date().timeIntervalSince1970,
                        "isDemo": true
                    ]
                    
                    userDocument.setData(userData) { error in
                        if let error = error {
                            print("Demo kullanıcı bilgileri kaydedilirken hata: \(error)")
                        }
                    }
                }
            }
        }
    }
}
