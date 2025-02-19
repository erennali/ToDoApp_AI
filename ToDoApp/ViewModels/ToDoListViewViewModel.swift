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
    
    private let userId: String
    private var db: Firestore
    private var timer: Timer?
    
    init(userId: String) {
        self.userId = userId
        self.db = Firestore.firestore()
        
        // Start checking for expired tasks
        startExpirationCheck()
        // Schedule daily notification
        scheduleDailyNotification()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func delete(id: String) {
        db.collection("users")
            .document(userId)
            .collection("todos")
            .document(id)
            .delete()
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
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching tasks for notification: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let calendar = Calendar.current
                let now = Date()
                let todayStart = calendar.startOfDay(for: now)
                let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart)!
                
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
