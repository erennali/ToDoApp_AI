//
//  WelcomeView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 7.02.2025.
//

import SwiftUI
import FirebaseAuth

struct WelcomeView: View {
    @State private var isActive = false
    @State private var logoSize: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var textOffset: CGFloat = 50
    @State private var imageOpacity: Double = 0.7
    
    // Reference to ProfileViewViewModel for prefetching
    @StateObject private var profileViewModel = ProfileViewViewModel.shared
    
    var body: some View {
        ZStack {
            // Background image with overlay
            Image("welcome2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(imageOpacity)
            
            // Content
            VStack(spacing: 30) {
                // Logo ve Animasyon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 150, height: 150)
                        .blur(radius: 10)
                    
                    Image(systemName: "checklist")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .scaleEffect(logoSize)
                }
                .padding(.bottom, 20)
                
                // Metin
                VStack(spacing: 16) {
                    Text("Hoş Geldiniz!")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Başarı tesadüf değildir")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .offset(y: textOffset)
                .opacity(opacity)
            }
            .padding(.top, -50)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .onAppear {
            // Splash screen gösterilirken user bilgilerini önceden yükle
            prefetchUserData()
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoSize = 1.0
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                opacity = 1.0
                textOffset = 0
                imageOpacity = 1.0
            }
            
            // Ana ekrana geçiş - kullanıcı verisi yüklenirken splash ekranı kalır
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
    
    // Kullanıcı verilerini önceden yükle
    private func prefetchUserData() {
        if let user = Auth.auth().currentUser {
            print("Splash screen: Prefetching user data for \(user.uid)")
            // ProfileViewViewModel'deki fetch işlemi otomatik olarak çalışacak
            // Bu sayede MainView'a geçmeden önce veriler yüklenmiş olacak
        } else {
            print("Splash screen: No user logged in")
        }
    }
}

#Preview {
    WelcomeView()
}
