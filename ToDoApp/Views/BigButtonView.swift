//
//  BigButtonView.swift
//  ToDoApp
//
//  Created by Eren Ali Koca on 5.02.2025.
//

import SwiftUI

struct BigButton: View {
    
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(.primary)
                
                Text(title)
                    .foregroundStyle(.white)
                
            }
            }).frame(height: 50)
            .padding(.horizontal)
            .padding(.bottom)
    }
}

#Preview {
    BigButton(title: "String", action: {})
}
