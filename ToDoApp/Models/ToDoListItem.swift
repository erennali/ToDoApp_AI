//
//  ToDoListItem.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import Foundation

struct ToDoListItem : Codable , Identifiable {
    let id : String
    let title : String
    let description : String?
    let dueDate : TimeInterval
    let createdDate : TimeInterval
    var isDone : Bool
    
    mutating func setDone (_ state : Bool) {
        isDone = state
    }
}
