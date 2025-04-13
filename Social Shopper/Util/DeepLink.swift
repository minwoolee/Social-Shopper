import Foundation

enum DeepLink {
    static let scheme = "socialshopper"
    static let host = "app"
    
    static func productURL(id: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/product/\(id)"
        return components.url
    }
    
    static func threadURL(productId: String, threadId: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/product/\(productId)/thread/\(threadId)"
        return components.url
    }
    
    static func handleURL(_ url: URL) -> DeepLinkDestination? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == scheme,
              components.host == host else {
            return nil
        }
        
        let pathComponents = components.path.split(separator: "/")
        
        if pathComponents.count >= 2 && pathComponents[1] == "product" {
            if pathComponents.count >= 4 && pathComponents[3] == "thread" {
                let productId = String(pathComponents[2])
                let threadId = String(pathComponents[4])
                return .thread(productId: productId, threadId: threadId)
            }
            return .product(id: String(pathComponents[2]))
        }
        
        return nil
    }
}

enum DeepLinkDestination: Equatable, Identifiable {
    case product(id: String)
    case thread(productId: String, threadId: String)
    
    var id: String {
        switch self {
        case .product(let id):
            return "product_\(id)"
        case .thread(let productId, let threadId):
            return "thread_\(productId)_\(threadId)"
        }
    }
}
