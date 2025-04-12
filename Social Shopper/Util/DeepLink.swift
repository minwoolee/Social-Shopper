import Foundation

enum DeepLink {
    static let scheme = "socialshopper"
    static let host = "product"

    static func productURL(id: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/product/\(id)"
        return components.url
    }

    static func handleURL(_ url: URL) -> DeepLinkDestination? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              components.scheme == scheme,
              components.host == host else {
            return nil
        }

        let pathComponents = components.path.split(separator: "/")

        if !pathComponents.isEmpty {
            let productId = String(pathComponents[0])
            return .product(id: productId)
        }

        return nil
    }
}

enum DeepLinkDestination: Equatable {
    case product(id: String)
}
