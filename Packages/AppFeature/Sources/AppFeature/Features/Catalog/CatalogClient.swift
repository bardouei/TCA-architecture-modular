import AppDependencies
import ComposableArchitecture
import Foundation
import NetworkCore

public struct CatalogClient: Sendable {
    public var fetchProducts: @Sendable (String?) async throws -> [Product]
}

private enum CatalogClientKey: DependencyKey {
    static let liveValue = CatalogClient { query in
        @Dependency(\.networkClient) var networkClient
        let value = query?.trimmingCharacters(in: .whitespacesAndNewlines)
        let search = value.flatMap { $0.isEmpty ? nil : $0 }
        let response = try await networkClient.send(
            NetworkRequest(
                baseURL: URL(string: "https://dummyjson.com"),
                path: search == nil ? "/products" : "/products/search",
                queryParameters: search.map { ["q": $0] } ?? ["limit": "30"]
            )
        )
        return try JSONDecoder().decode(ProductsResponse.self, from: response.data).products
    }

    static let testValue = CatalogClient { _ in [] }
}

public extension DependencyValues {
    var catalogClient: CatalogClient {
        get { self[CatalogClientKey.self] }
        set { self[CatalogClientKey.self] = newValue }
    }
}
