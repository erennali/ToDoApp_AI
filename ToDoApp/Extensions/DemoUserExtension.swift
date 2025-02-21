import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

extension Auth {
    static func isDemoUser(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            if let isDemo = snapshot?.data()?["isDemo"] as? Bool {
                completion(isDemo)
            } else {
                completion(false)
            }
        }
    }
    
    static func showDemoAlert(navigateToRegister: @escaping () -> Void, navigateToLogin: @escaping () -> Void) -> Alert {
        return Alert(
            title: Text("Demo Hesap Kısıtlaması"),
            message: Text("Bu özelliği kullanabilmek için lütfen bir hesap oluşturun veya giriş yapın."),
            primaryButton: .default(Text("Hesap Oluştur"), action: {
                // Önce demo kullanıcı oturumunu kapat
                try? Auth.auth().signOut()
                // Demo kullanıcı verilerini temizle
                clearDemoUserData()
                // RegisterView'a yönlendir
                navigateToRegister()
            }),
            secondaryButton: .default(Text("Giriş Yap"), action: {
                // Önce demo kullanıcı oturumunu kapat
                try? Auth.auth().signOut()
                // Demo kullanıcı verilerini temizle
                clearDemoUserData()
                // LoginView'a yönlendir
                navigateToLogin()
            })
        )
    }
    
    static func clearDemoUserData() {
        // Demo kullanıcı verilerini UserDefaults'tan temizle
        if let userId = Auth.auth().currentUser?.uid {
            UserDefaults.standard.removeObject(forKey: "isDemo_\(userId)")
        }
        UserDefaults.standard.synchronize()
    }
}
