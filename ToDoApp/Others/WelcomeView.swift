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

    var body: some View {
        ZStack {
            Image("welcome2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Logo ve Animasyon
                Image(systemName: "checklist")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
                    .scaleEffect(logoSize)
                    .animation(.easeIn(duration: 1.5), value: logoSize)
                    .onAppear {
                        logoSize = 1.2
                    }
                
                // Metin
                VStack {
                    Text("Hoş Geldiniz!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.gray)
                    Text("Başarı tesadüf değildir")
                        .font(.title2)
                        .foregroundColor(.gray)
                }

            }
            .padding(.top, -100) // Metni yukarı taşı
            .onAppear {
                // 3 saniye sonra ana ekrana geçiş
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}
