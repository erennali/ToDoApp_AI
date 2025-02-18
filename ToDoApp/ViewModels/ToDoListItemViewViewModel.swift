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
        self.item = item
        self.isDone = !item.isDone
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(uid)
            .collection("todos")
            .document(item.id)
            .updateData(["isDone": self.isDone]) { [weak self] error in
                if let error = error {
                    print("Error updating document: \(error)")
                    // Revert the local state if update fails
                    DispatchQueue.main.async {
                        self?.isDone = !self!.isDone
                    }
                }
            }
    }
}
