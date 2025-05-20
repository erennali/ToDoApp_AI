//
//  ToDoListItemViewViewModel.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ToDoListItemViewViewModel : ObservableObject {
    @Published var isDone: Bool = false
    private var item: ToDoListItem?
    
    init() {}
    
    func toggleIsDone(item: ToDoListItem) {
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
                }
            }
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
}
