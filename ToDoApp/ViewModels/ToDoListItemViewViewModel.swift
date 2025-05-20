//
//  ToDoListItemViewViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// Notification name for todo item status changes
extension Notification.Name {
    static let todoStatusChanged = Notification.Name("todoStatusChanged")
}

class ToDoListItemViewViewModel : ObservableObject {
    @Published var isDone: Bool = false
    private var item: ToDoListItem?
    
    init() {
        // Listen for todo status change notifications
        setupNotificationObserver()
    }
    
    deinit {
        // Remove observer when view model is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTodoStatusChanged),
            name: .todoStatusChanged,
            object: nil
        )
    }
    
    @objc private func handleTodoStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let todoId = userInfo["todoId"] as? String,
              let newStatus = userInfo["isDone"] as? Bool,
              let currentItem = self.item, // Only process if we have an item
              currentItem.id == todoId // And it matches the updated item's ID
        else {
            return
        }
        
        // Update the local state if this is the same item
        DispatchQueue.main.async { [weak self] in
            self?.isDone = newStatus
        }
    }
    
    func toggleIsDone(item: ToDoListItem) {
        // Store a reference to the current item
        self.item = item
        
        // Toggle the state locally first for immediate UI feedback
        let newState = !item.isDone
        self.isDone = newState
        
        // Store a local copy of the updated item
        var updatedItem = item
        updatedItem.setDone(newState)
        self.item = updatedItem
        
        // Update Firestore
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(uid)
            .collection("todos")
            .document(item.id)
            .updateData(["isDone": newState]) { [weak self] error in
                if let error = error {
                    print("Error updating document: \(error)")
                    // Revert the local state if update fails
                    DispatchQueue.main.async {
                        self?.isDone = !newState
                    }
                } else {
                    // Notify other views about the change
                    self?.notifyStatusChange(todoId: item.id, isDone: newState)
                }
            }
    }
    
    private func notifyStatusChange(todoId: String, isDone: Bool) {
        NotificationCenter.default.post(
            name: .todoStatusChanged,
            object: nil,
            userInfo: ["todoId": todoId, "isDone": isDone]
        )
    }
    
    func delete(id: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(uid)
            .collection("todos")
            .document(id)
            .delete { error in
                if let error = error {
                    print("Error deleting document: \(error)")
                }
            }
    }
    
    // Method to update the stored item reference
    func setItem(_ todoItem: ToDoListItem) {
        self.item = todoItem
    }
}
