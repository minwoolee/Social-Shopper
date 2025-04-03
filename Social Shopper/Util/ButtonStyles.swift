import SwiftUI

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    let isLoading: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                configuration.label
            }
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    let isLoading: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            } else {
                configuration.label
            }
        }
        .padding()
        .background(Color.white)
        .foregroundColor(.blue)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: 1)
        )
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Success Button Style
struct SuccessButtonStyle: ButtonStyle {
    let isLoading: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                configuration.label
            }
        }
        .padding()
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(8)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Danger Button Style
struct DangerButtonStyle: ButtonStyle {
    let isLoading: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                configuration.label
            }
        }
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(8)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Icon Button Style
struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions
extension View {
    func primaryButton(isLoading: Bool = false) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isLoading: isLoading))
    }
    
    func secondaryButton(isLoading: Bool = false) -> some View {
        self.buttonStyle(SecondaryButtonStyle(isLoading: isLoading))
    }
    
    func successButton(isLoading: Bool = false) -> some View {
        self.buttonStyle(SuccessButtonStyle(isLoading: isLoading))
    }
    
    func dangerButton(isLoading: Bool = false) -> some View {
        self.buttonStyle(DangerButtonStyle(isLoading: isLoading))
    }
    
    func iconButton() -> some View {
        self.buttonStyle(IconButtonStyle())
    }
} 