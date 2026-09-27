import Foundation

public struct Product: Codable, Equatable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let description: String
    public let category: String
    public let price: Double
    public let rating: Double
    public let stock: Int
    public let thumbnail: URL
    public let images: [URL]
}

struct ProductsResponse: Decodable, Sendable {
    let products: [Product]
}
