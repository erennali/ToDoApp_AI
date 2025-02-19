//
//  DetailsItemView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 18.02.2025.
//

import SwiftUI

struct DetailsItemView: View {
    let item: ToDoListItem
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ToDoListItemViewViewModel()
    
    private var isOverdue: Bool {
        Date(timeIntervalSince1970: item.dueDate) < Date()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Status Card
                        VStack(spacing: 15) {
                            // Title
                            Text(item.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            if isOverdue {
                                HStack(spacing: 15) {
                                    Image (systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text("Süresi Geçmiş!")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.15))
                                .cornerRadius(20)
                            }
                            
                            // Status Badges
                            HStack(spacing: 15) {
                                // Completion Status
                                HStack(spacing: 6) {
                                    Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isDone ? .green : .orange)
                                    Text(item.isDone ? "Tamamlandı" : "Devam Ediyor")
                                        .font(.subheadline)
                                        .foregroundColor(item.isDone ? .green : .orange)
                                    
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    (item.isDone ? Color.green : Color.orange)
                                        .opacity(0.15)
                                )
                                .cornerRadius(20)
                                
                                // Alarm Status
                                if item.onClock {
                                    HStack(spacing: 6) {
                                        Image(systemName: "bell.fill")
                                        Text("Zamanlanmış")
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        // Description Card
                        if let description = item.description, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Açıklama", systemImage: "text.alignleft")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text(description)
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Dates Card
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Tarih Bilgileri", systemImage: "calendar")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            VStack(spacing: 12) {
                                dateRow(
                                    icon: "calendar.badge.clock",
                                    title: "Bitiş Tarihi:",
                                    date: Date(timeIntervalSince1970: item.dueDate),
                                    style: .date
                                )
                                
                                dateRow(
                                    icon: "clock.fill",
                                    title: "Bitiş Saati:",
                                    date: Date(timeIntervalSince1970: item.dueDate),
                                    style: .time
                                )
                                
                                dateRow(
                                    icon: "plus.circle.fill",
                                    title: "Oluşturulma:",
                                    date: Date(timeIntervalSince1970: item.createdDate),
                                    style: .date
                                )
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Görev Detayı")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.toggleIsDone(item: item)
                        dismiss()
                    } label: {
                        Image(systemName: item.isDone ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .foregroundColor(item.isDone ? .red : .green)
                    }
                }
            }
        }
    }
    
    private func dateRow(icon: String, title: String, date: Date, style: Text.DateStyle) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(date, style: style)
                .foregroundColor(.secondary)
        }
        .environment(\.locale, Locale(identifier: "tr_TR"))
    }
}

#Preview {
    DetailsItemView(item: ToDoListItem(
        id: "123",
        title: "Örnek Görev Başlığı",
        description: "Bu bir örnek görev açıklamasıdır. Görevin detayları burada yer alır ve kullanıcı bu detayları görüntüleyebilir.",
        dueDate: Date().timeIntervalSince1970,
        createdDate: Date().timeIntervalSince1970,
        isDone: false,
        onClock: true
    ))
}
