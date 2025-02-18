//
//  ToDoListItem.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import Foundation

struct ToDoListItem: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String?
    let dueDate: TimeInterval
    let createdDate: TimeInterval
    var isDone: Bool
    var onClock: Bool 
    
    mutating func setDone(_ state: Bool) {
        isDone = state
    }
    
    // Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ToDoListItem, rhs: ToDoListItem) -> Bool {
        lhs.id == rhs.id
    }
}
