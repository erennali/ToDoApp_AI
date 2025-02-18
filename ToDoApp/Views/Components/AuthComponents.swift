import SwiftUI

// MARK: - Field Types
enum AuthField {
    case name, email, password
}

// MARK: - Background Gradient
struct AuthBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Input Field
struct AuthInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let field: AuthField
    var isSecure: Bool = false
    var focusedField: FocusState<AuthField?>.Binding
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused(focusedField, equals: field)
                        .textContentType(.password)
                        .autocapitalization(.none)
                } else {
                    TextField(placeholder, text: $text)
                        .focused(focusedField, equals: field)
                        .textContentType(field == .email ? .emailAddress : .username)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}

// MARK: - Auth Button
struct AuthButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let isLoading: Bool
    
    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack {
                        Image(systemName: icon)
                        Text(title)
                            .fontWeight(.semibold)
                    }
                }
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
        .disabled(isLoading)
        .padding(.top, 10)
    }
}

// MARK: - Form Card
struct AuthFormCard<Content: View>: View {
    let title: String
    let errorMessage: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
} 