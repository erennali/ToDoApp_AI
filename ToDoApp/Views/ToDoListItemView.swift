//
//  ToDoListItemView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct ToDoListItemView: View {
    @StateObject var viewModel = ToDoListItemViewViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let item: ToDoListItem
    
    // Track the completion status in a local state variable
    @State private var isItemDone: Bool = false
    
    private var isOverdue: Bool {
        Date(timeIntervalSince1970: item.dueDate) < Date()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: horizontalSizeClass == .regular ? 20 : 15) {
            // Task Status Button
            Button {
                viewModel.toggleIsDone(item: item)
            } label: {
                Image(systemName: isItemDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: horizontalSizeClass == .regular ? 28 : 24))
                    .foregroundStyle(isItemDone ? Color.green : Color.blue)
                    .contentShape(Rectangle())
            }
            
            // Task Details
            VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 6 : 4) {
                Text(item.title)
                    .font(.system(size: horizontalSizeClass == .regular ? 18 : 16, weight: .medium))
                    .foregroundColor(isItemDone ? .gray : .primary)
                    .strikethrough(isItemDone)
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: horizontalSizeClass == .regular ? 14 : 12))
                        .foregroundColor(.gray)
                    
                    Text(dateFormatter.string(from: Date(timeIntervalSince1970: item.dueDate)))
                        .font(.system(size: horizontalSizeClass == .regular ? 14 : 12))
                        .foregroundColor(.gray)
                }
            }
            .environment(\.locale, Locale(identifier: "tr_TR"))
            
            Spacer()
            
            // Priority Indicator (if needed)
            HStack(spacing: horizontalSizeClass == .regular ? 12 : 8) {
                if item.onClock {
                    Image(systemName: "bell.fill")
                        .font(.system(size: horizontalSizeClass == .regular ? 16 : 14))
                        .foregroundColor(isItemDone ? .gray : .orange)
                }
                
                if isOverdue && !isItemDone {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: horizontalSizeClass == .regular ? 16 : 14))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, horizontalSizeClass == .regular ? 12 : 8)
        .padding(.horizontal, horizontalSizeClass == .regular ? 16 : 12)
        .onAppear {
            // Tell the viewModel which item we're tracking
            viewModel.setItem(item)
            
            // Initialize local state from the item
            isItemDone = item.isDone
            viewModel.isDone = item.isDone
        }
        .onChange(of: viewModel.isDone) { newValue in
            // Update our local state when the view model changes
            isItemDone = newValue
        }
        // Listen for status changes in this item from other views
        .onReceive(NotificationCenter.default.publisher(for: .todoStatusChanged)) { notification in
            guard let userInfo = notification.userInfo,
                  let todoId = userInfo["todoId"] as? String,
                  let newStatus = userInfo["isDone"] as? Bool,
                  item.id == todoId // Only update if this is the same item
            else {
                return
            }
            
            // Update our local state to reflect the change
            DispatchQueue.main.async {
                isItemDone = newStatus
            }
        }
    }
}

#Preview {
    Group {
        ToDoListItemView(item: .init(
            id: "123",
            title: "Abone Ol",
            description: "",
            dueDate: Date().timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            onClock: true
        ))
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .environment(\.horizontalSizeClass, .compact) // iPhone preview
        
        ToDoListItemView(item: .init(
            id: "123",
            title: "Abone Ol",
            description: "",
            dueDate: Date().timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            onClock: true
        ))
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .environment(\.horizontalSizeClass, .regular) // iPad preview
    }
}
