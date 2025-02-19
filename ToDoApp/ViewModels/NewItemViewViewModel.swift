//
//  NewItemViewViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//
import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewItemViewViewModel : ObservableObject {
    @Published var title = ""
    @Published var dueDate = Date()
    @Published var showAlert = false
    @Published var description = ""
    @Published var onClock: Bool = false
    
    init(initialTitle: String = "") {
            self.title = initialTitle // Başlangıç değeri ataması
        }
    
    func save() {
        guard canSave else {
            return
        }
        
        guard let uId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let newItemId = UUID().uuidString
        
        let newItem = ToDoListItem(id: newItemId, title: title, description: description , dueDate: dueDate.timeIntervalSince1970, createdDate: Date().timeIntervalSince1970, isDone: false , onClock: onClock)
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(uId)
            .collection("todos")
            .document(newItemId)
            .setData(newItem.asDictionary())
        
        
        if onClock {
            let targetNotificationTime = Date(timeIntervalSince1970: newItem.dueDate).addingTimeInterval(-1800)
            let timeIntervalFromNow = targetNotificationTime.timeIntervalSince(Date())
            
            if timeIntervalFromNow > 0 {
                let notificationDate = Date().addingTimeInterval(timeIntervalFromNow)
                scheduleNotification(
                    message: "Hatırlatma! \(newItem.title) adlı görevin için son 30 dakika!",
                    sendAfter: notificationDate
                )
            }
        }
    }
    
    var canSave : Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        guard dueDate >= Date().addingTimeInterval(-86400) else {
            return false
        }
        
        return true
    }
    
    func scheduleNotification(message: String, sendAfter: Date) {
        guard let appId = EnvironmentManager.oneSignalAppId else {
            print("Hata: OneSignal App ID bulunamadı")
            return
        }
        
        guard let apiKey = EnvironmentManager.oneSignalRestApiKey else {
            print("Hata: OneSignal REST API Key bulunamadı")
            return
        }
        
        let url = URL(string: "https://onesignal.com/api/v1/notifications")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = ISO8601DateFormatter()
        let sendAfterString = dateFormatter.string(from: sendAfter)
        
        let parameters: [String: Any] = [
            "app_id": appId,
            "contents": ["en": message],
            "send_after": sendAfterString,
            "included_segments": ["All"]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("JSON serileştirme hatası:", error.localizedDescription)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Bildirim gönderilirken hata oluştu:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Bildirim başarıyla gönderildi:", responseString)
                    }
                } else {
                    print("Sunucu hatası:", httpResponse.statusCode)
                }
            }
        }
        
        task.resume()
    }
}
