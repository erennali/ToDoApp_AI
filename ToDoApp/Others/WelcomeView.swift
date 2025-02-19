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
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoSize = 1.0
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                opacity = 1.0
                textOffset = 0
                imageOpacity = 1.0
            }
            
            // Ana ekrana geçiş
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}
