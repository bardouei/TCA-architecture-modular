//
//  PostsClient.swift
//  FeatureHome
//

import ComposableArchitecture
import DomainCore
import Foundation
import NetworkCore

public struct PostsClient: Sendable {
    public var fetchPosts: @Sendable () async throws -> [EntityPost]

    public init(fetchPosts: @escaping @Sendable () async throws -> [EntityPost]) {
        self.fetchPosts = fetchPosts
    }
}

private enum PostsClientKey: DependencyKey {
    static let liveValue = PostsClient {
        let response = try await AnyNetworkClient.live.send(
            NetworkRequest(path: "/posts")
        )

        return try JSONDecoder().decode([EntityPost].self, from: response.data)
    }

    static let testValue = PostsClient {
        throw NetworkError.invalidRequest
    }
}

public extension DependencyValues {
    var postsClient: PostsClient {
        get { self[PostsClientKey.self] }
        set { self[PostsClientKey.self] = newValue }
    }
}
