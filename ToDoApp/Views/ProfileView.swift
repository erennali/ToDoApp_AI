//
//  ProfileView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseAuth

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewViewModel.shared
    @StateObject private var storeManager = StoreManager.shared
    @State private var showImagePicker = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: Image?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showingDemoAlert = false
    @State private var isDemo = false
    @State private var showingRegisterView = false
    @State private var showingLoginView = false
    
    init() {}
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    // Yükleme göstergesi
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.5)
                        
                        Text("Profil bilgileriniz yükleniyor...")
                            .font(.callout)
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                } else if viewModel.user == nil {
                    // Kullanıcı yok, giriş ekranını göster
                    LogInView()
                } else {
                    // Normal kullanıcı profil görünümü
                    profileContent
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingRegisterView) {
                RegisterView()
            }
            .sheet(isPresented: $showingLoginView) {
                LogInView()
            }
            .onAppear {
                checkDemoStatus()
            }
        }
        .navigationViewStyle(horizontalSizeClass == .regular ? .stack : .stack)
    }
    
    // Profil içeriğini ayrı bir View olarak tanımla
    @ViewBuilder
    private var profileContent: some View {
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
                    VStack(spacing: horizontalSizeClass == .regular ? 35 : 25) {
                        // Profil Başlığı
                        profileHeader(user: user)
                        
                        // iPad için grid layout
                        if horizontalSizeClass == .regular {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 20) {
                                // Kişisel Bilgiler Kartı
                                profileCard {
                                    VStack(spacing: 20) {
                                        infoRow(icon: "person.fill", title: "Kullanıcı Adı", value: user.name)
                                        Divider()
                                        infoRow(icon: "envelope.fill", title: "Email", value: user.email)
                                    }
                                }
                                
                                // AI Mesaj Kotası ve Katılım Bilgisi
                                profileCard {
                                    VStack(spacing: 20) {
                                        infoRow(
                                            icon: "brain.head.profile",
                                            title: "AI Mesaj Hakkı",
                                            value: "\(user.aiMessageQuota) mesaj"
                                        )
                                        Divider()
                                        infoRow(
                                            icon: "calendar.badge.clock",
                                            title: "Katılım Tarihi",
                                            value: "\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .shortened))"
                                        )
                                        
                                        // Kredi Satın Alma Bölümü
                                        creditPurchaseSection()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            // iPhone için normal layout
                            VStack(spacing: 15) {
                                // Kişisel Bilgiler Kartı
                                profileCard {
                                    VStack(spacing: 15) {
                                        infoRow(icon: "person.fill", title: "Kullanıcı Adı", value: user.name)
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
                                        value: "\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .shortened))"
                                    )
                                }
                                
                                // Kredi Satın Alma Bölümü
                                creditPurchaseSection()
                            }
                            .padding(.top)
                            .padding(.horizontal)
                        }
                        
                        // Çıkış Yap Butonu
                        Button(action: { viewModel.logOut() }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: horizontalSizeClass == .regular ? 20 : 16))
                                Text("Çıkış Yap")
                                    .font(.system(size: horizontalSizeClass == .regular ? 20 : 16))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: horizontalSizeClass == .regular ? 300 : .infinity)
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
                        .padding(.horizontal, horizontalSizeClass == .regular ? 0 : 16)
                        
                        // Hesap Silme Butonu
                        Button(action: { 
                            showingDemoAlert = true 
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Hesabı Sil")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                        .alert(isPresented: $showingDemoAlert) {
                            Alert(title: Text("Hesabı Sil"), 
                                 message: Text("Hesabınızı silmek istediğinize emin misiniz?"), 
                                 primaryButton: .destructive(Text("Sil")) {
                                     // Hesap silme işlemi
                                     viewModel.deleteAccount()
                                 }, 
                                 secondaryButton: .cancel())
                        }
                    }
                }
            }
        }
    }
    
    // Profil Başlığı
    private func profileHeader(user: User) -> some View {
        VStack(spacing: horizontalSizeClass == .regular ? 20 : 15) {
            // Profil Resmi
            PhotosPicker(selection: $selectedImage, matching: .images) {
                ZStack {
                    if viewModel.isImageUploading {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: horizontalSizeClass == .regular ? 160 : 120, height: horizontalSizeClass == .regular ? 160 : 120)
                            ProgressView()
                                .scaleEffect(1.5)
                        }
                    } else if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: horizontalSizeClass == .regular ? 160 : 120, height: horizontalSizeClass == .regular ? 160 : 120)
                            .clipShape(Circle())
                            .shadow(color: .purple.opacity(0.3), radius: 10)
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.5), .purple.opacity(0.5)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: horizontalSizeClass == .regular ? 160 : 120, height: horizontalSizeClass == .regular ? 160 : 120)
                            .shadow(color: .purple.opacity(0.3), radius: 10)
                        
                        Text(String(user.name.prefix(1)).uppercased())
                            .font(.system(size: horizontalSizeClass == .regular ? 70 : 50, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: horizontalSizeClass == .regular ? 160 : 120, height: horizontalSizeClass == .regular ? 160 : 120)
                }
            }
            .onChange(of: selectedImage) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                viewModel.uploadProfileImage(uiImage)
                            }
                        }
                    }
                }
            }
            
            // Kullanıcı Adı
            Text(user.name)
                .font(horizontalSizeClass == .regular ? .title : .title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
    
    // Profil Kartı Görünümü
    private func profileCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(horizontalSizeClass == .regular ? 24 : 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
    
    // Bilgi Satırı Görünümü
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: horizontalSizeClass == .regular ? 20 : 15) {
            Image(systemName: icon)
                .font(.system(size: horizontalSizeClass == .regular ? 24 : 20))
                .foregroundColor(.blue)
                .frame(width: horizontalSizeClass == .regular ? 36 : 30)
            
            VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 6 : 4) {
                Text(title)
                    .font(horizontalSizeClass == .regular ? .title3 : .subheadline)
                    .foregroundColor(.gray)
                Text(value)
                    .font(horizontalSizeClass == .regular ? .title3 : .body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
    
    // Kredi Satın Alma Bölümü
    private func creditPurchaseSection() -> some View {
        VStack(spacing: 15) {
            Text("Kredi Satın Al")
                .font(.headline)
                .foregroundColor(.primary)
            
            if storeManager.products.isEmpty {
                Text("Ürünler yükleniyor...")
                    .foregroundColor(.gray)
            } else {
                ForEach(storeManager.products) { product in
                    Button(action: {
                        Task {
                            await storeManager.purchase(product)
                        }
                    }) {
                        HStack {
                            Text(product.displayName)
                                .font(.subheadline)
                                .bold()
                            Spacer()
                            Text(product.displayPrice)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            
            if let error = storeManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top)
    }
    
    private func checkDemoStatus() {
        Auth.isDemoUser { isDemoUser in
            DispatchQueue.main.async {
                isDemo = isDemoUser
            }
        }
    }
}

#Preview {
    Group {
        ProfileView()
            .environment(\.horizontalSizeClass, .compact)
        ProfileView()
            .environment(\.horizontalSizeClass, .regular)
    }
}
