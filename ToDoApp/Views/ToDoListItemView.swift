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
                Image(systemName: viewModel.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: horizontalSizeClass == .regular ? 28 : 24))
                    .foregroundStyle(viewModel.isDone ? Color.green : Color.blue)
                    .contentShape(Rectangle())
            }
            
            // Task Details
            VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 6 : 4) {
                Text(item.title)
                    .font(.system(size: horizontalSizeClass == .regular ? 18 : 16, weight: .medium))
                    .foregroundColor(viewModel.isDone ? .gray : .primary)
                    .strikethrough(viewModel.isDone)
                
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
                        .foregroundColor(item.isDone ? .gray : .orange)
                }
                
                if isOverdue && item.isDone == false {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: horizontalSizeClass == .regular ? 16 : 14))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, horizontalSizeClass == .regular ? 12 : 8)
        .padding(.horizontal, horizontalSizeClass == .regular ? 16 : 12)
        .onAppear {
            viewModel.isDone = item.isDone
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
