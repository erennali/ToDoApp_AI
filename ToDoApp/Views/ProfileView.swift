//
//  ProfileView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewViewModel()
    
    init() {}
    
    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan gradyanı
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if let user = viewModel.user {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Profil Başlığı
                            profileHeader(user: user)
                            
                            // Profil Kartları
                            VStack(spacing: 15) {
                                // Kişisel Bilgiler Kartı
                                profileCard {
                                    VStack(spacing: 15) {
                                        infoRow(icon: "person.fill", title: "İsim", value: user.name)
                                        Divider()
                                        infoRow(icon: "envelope.fill", title: "Email", value: user.email)
                                    }
                                }
                                
                                // AI Mesaj Kotası Kartı
                                profileCard {
                                    infoRow(
                                        icon: "brain.head.profile",
                                        title: "AI Mesaj Hakkı",
                                        value: "\(user.aiMessageQuota) mesaj"
                                    )
                                }
                                
                                // Katılım Bilgisi Kartı
                                profileCard {
                                    infoRow(
                                        icon: "calendar.badge.clock",
                                        title: "Katılım Tarihi",
                                        value: Date(timeIntervalSince1970: user.joined).formatted(
                                            .dateTime.day().month().year()
                                        )
                                    )
                                    .environment(\.locale, Locale(identifier: "tr_TR"))
                                }
                                
                                // Çıkış Yap Butonu
                                Button(action: { viewModel.logOut() }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text("Çıkış Yap")
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.red.opacity(0.8), .orange.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(color: .red.opacity(0.3), radius: 5, x: 0, y: 3)
                                }
                                .padding(.top, 10)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 20)
                    }
                } else if viewModel.isLoading {
                    ProgressView("Yükleniyor...")
                        .scaleEffect(1.5)
                        .tint(.blue)
                } else {
                    Text("Kullanıcı bilgileri yüklenemedi")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.fetchUser()
        }
    }
    
    // Profil Başlığı
    private func profileHeader(user: User) -> some View {
        VStack(spacing: 15) {
            // Profil Resmi
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.5), .purple.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .purple.opacity(0.3), radius: 10)
                
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Kullanıcı Adı
            Text(user.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
    
    // Profil Kartı Görünümü
    private func profileCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
    
    // Bilgi Satırı Görünümü
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ProfileView()
}
