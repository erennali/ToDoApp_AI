//
//  NewItemView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct NewItemView: View {
    @Binding var newItemPresented: Bool
    @StateObject private var viewModel: NewItemViewViewModel
    let alinanMetin: String
    @Environment(\.dismiss) private var dismiss
    @State private var showingInfoAlert = false
    
    init(newItemPresented: Binding<Bool>, alinanMetin: String) {
        self._newItemPresented = newItemPresented
        self.alinanMetin = alinanMetin
        _viewModel = StateObject(
            wrappedValue: NewItemViewViewModel(initialTitle: alinanMetin)
        )
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
                        // Form Card
                        VStack(spacing: 20) {
                            // Title Field
                            inputField(
                                title: "Başlık",
                                text: $viewModel.title,
                                icon: "pencil.line"
                            )
                            
                            // Description Field
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Açıklama", systemImage: "text.alignleft")
                                    .foregroundColor(.gray)
                                TextEditor(text: $viewModel.description)
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            // Date Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Bitiş Tarihi", systemImage: "calendar")
                                    .foregroundColor(.gray)
                                DatePicker("", selection: $viewModel.dueDate)
                                    .datePickerStyle(.compact)
                                    .environment(\.locale, Locale(identifier: "tr_TR"))
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            // Alarm Toggle
                            HStack {
                                HStack(spacing: 4) {
                                    Label("Hatırlatıcı Kur", systemImage: "clock.badge")
                                        .foregroundColor(.gray)
                                    Button {
                                        showingInfoAlert = true
                                    } label: {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.blue)
                                    }
                                }
                                Spacer()
                                Toggle("", isOn: $viewModel.onClock)
                                    .tint(.blue)
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                            // Save Button
                            Button {
                                if viewModel.canSave {
                                    viewModel.save()
                                    dismiss()
                                } else {
                                    viewModel.showAlert = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Kaydet")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(color: .purple.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            .padding(.top, 10)
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
            .navigationTitle("Yeni Görev")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Hata"),
                    message: Text("Lütfen verilerin doğruluğunu kontrol ediniz.")
                )
            }
            .alert("Hatırlatıcı Bilgisi", isPresented: $showingInfoAlert) {
                Button("Anladım", role: .cancel) { }
            } message: {
                Text("Hatırlatıcı kurulduğunda, görevin bitiş tarihinden 30 dakika önce size bildirim gönderilecektir.")
            }
        }
    }
    
    private func inputField(
        title: String,
        text: Binding<String>,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .foregroundColor(.gray)
            TextField("", text: text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

#Preview {
    NewItemView(
        newItemPresented: Binding(
            get: { return true },
            set: { _ in }
        ),
        alinanMetin: "Test"
    )
}
