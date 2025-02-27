//
//  ToDoListViewViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import Foundation
import FirebaseFirestore

class ToDoListViewViewModel: ObservableObject {
    @Published var showingNewItemView = false
    
    let userId: String
    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    private var timer: Timer?
    
    init(userId: String) {
        self.userId = userId
        
        // Start checking for expired tasks
        startExpirationCheck()
        // Schedule daily notification
        scheduleDailyNotification()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func delete(id: String) {
        if !userId.isEmpty {
            // Firebase'den sil
            db.collection("users")
                .document(userId)
                .collection("todos")
                .document(id)
                .delete()
        } else {
            // Local storage'dan sil
            var items = getLocalItems()
            items.removeAll { $0.id == id }
            saveLocalItems(items)
        }
    }
    
    func toggleIsDone(item: ToDoListItem) {
        var itemCopy = item
        itemCopy.setDone(!item.isDone)
        
        if !userId.isEmpty {
            // Firebase'de güncelle
            db.collection("users")
                .document(userId)
                .collection("todos")
                .document(item.id)
                .setData(itemCopy.asDictionary())
        } else {
            // Local storage'da güncelle
            var items = getLocalItems()
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = itemCopy
                saveLocalItems(items)
            }
        }
    }
    
    // Local storage işlemleri
    private func getLocalItems() -> [ToDoListItem] {
        if let data = defaults.data(forKey: "todos"),
           let items = try? JSONDecoder().decode([ToDoListItem].self, from: data) {
            return items
        }
        return []
    }
    
    private func saveLocalItems(_ items: [ToDoListItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: "todos")
        }
    }
    
    func addItem(_ item: ToDoListItem) {
        if !userId.isEmpty {
            // Firebase'e ekle
            db.collection("users")
                .document(userId)
                .collection("todos")
                .document(item.id)
                .setData(item.asDictionary())
        } else {
            // Local storage'a ekle
            var items = getLocalItems()
            items.append(item)
            saveLocalItems(items)
        }
    }
    
    private func startExpirationCheck() {
        // Her saat başı kontrol et
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkExpiredTasks()
        }
        
        // İlk kontrolü hemen yap
        checkExpiredTasks()
    }
    
    private func checkExpiredTasks() {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let yesterdayTimestamp = yesterday.timeIntervalSince1970
        
        db.collection("users")
            .document(userId)
            .collection("todos")
            .whereField("dueDate", isLessThan: yesterdayTimestamp)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching expired tasks: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                for document in documents {
                    // Süresi 24 saatten fazla geçmiş ve tamamlanmamış görevleri sil
                    if let isDone = document.data()["isDone"] as? Bool, !isDone {
                        self?.delete(id: document.documentID)
                    }
                }
            }
    }
    
    private func scheduleDailyNotification() {
        // Get today's tasks and schedule notification
        db.collection("users")
            .document(userId)
            .collection("todos")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching tasks for notification: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let calendar = Calendar.current
                let now = Date()
                let todayStart = calendar.startOfDay(for: now)
               
                
                let todayTasks = documents.filter { document in
                    if let dueDate = document.data()["dueDate"] as? TimeInterval,
                       let isDone = document.data()["isDone"] as? Bool,
                       !isDone {
                        let taskDate = Date(timeIntervalSince1970: dueDate)
                        return calendar.isDate(taskDate, inSameDayAs: now)
                    }
                    return false
                }
                
                // Update notification with today's task count
                NotificationManager.shared.updateNotificationWithTaskCount(todayTasks.count)
            }
    }
}
