//
//  HeaderView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        ZStack {
            // Arka plan gradient'i
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .cornerRadius(20)
                .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
                .frame(width: 350, height: 250)
            
            // İçerik
            VStack(spacing: 20) {
                Image("brain_2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing),
                                    lineWidth: 4)
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    .padding(.top, 20)
                
                VStack(spacing: 5) {
                    Text("Görev Yönetimi : AI")
                        .font(.system(size: 35, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.2), radius: 5, x: 0, y: 2)
                    
              
                }
            }
        }
        .padding(.top, 50)
        .padding(.horizontal, 20)
    }
}

#Preview {
    HeaderView()
}
