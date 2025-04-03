import Foundation
import SwiftUI

enum AppError: LocalizedError {
    case networkError(String)
    case authenticationError(String)
    case databaseError(String)
    case validationError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .databaseError(let message):
            return "Database Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .unknownError(let message):
            return "Unknown Error: \(message)"
        }
    }
}

// MARK: - Error Handling Protocol
protocol ErrorHandling {
    func handleError(_ error: AppError)
}

// MARK: - Error Alert View
struct ErrorAlert: ViewModifier {
    let error: AppError?
    let dismissAction: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: .constant(error != nil)) {
                Button("OK", role: .cancel) {
                    dismissAction()
                }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
    }
}

extension View {
    func errorAlert(error: AppError?, dismissAction: @escaping () -> Void) -> some View {
        modifier(ErrorAlert(error: error, dismissAction: dismissAction))
    }
} 
