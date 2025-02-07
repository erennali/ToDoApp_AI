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
            VStack {
                            Image(systemName: "sun.max.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.orange)
                                .scaleEffect(logoSize)
                                .animation(.easeIn(duration: 1.5), value: logoSize)
                                .onAppear {
                                    logoSize = 1.2
                                }

                            Text("Apart Uygulamanıza Hoş Geldiniz!")
                                .font(.title)
                                .bold()
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                        }
                        .onAppear {
                            // 3 saniye sonra ana ekrana geçiş
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
