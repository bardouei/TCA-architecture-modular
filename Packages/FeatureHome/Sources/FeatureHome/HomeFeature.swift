//
//  HomeFeature.swift
//  HomeFeature
//
//  Created by baner on 12/12/25.
//

import ComposableArchitecture
import NetworkCore
import TCAAdapters
import Foundation

@Reducer
public struct HomeFeature {

    public init() {}

    // MARK: - State
    @ObservableState
    public struct State: Equatable {
        public var posts: [Post]
        public var isLoading: Bool
        public var error: String?

        public init(
            posts: [Post] = [],
            isLoading: Bool = false,
            error: String? = nil
        ) {
            self.posts = posts
            self.isLoading = isLoading
            self.error = error
        }
    }

    // MARK: - Action
    public enum Action: Equatable {
        case onAppear
        case cachedPostsLoaded([Post])
        case postsResponse(TaskResult<[Post]>)
    }

    // MARK: - Dependencies
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.cache) var cache

    // MARK: - Reducer
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            // 1️⃣ View appeared
            case .onAppear:
                state.isLoading = true
                let network = networkClient
                let cache = cache

                return .run { send in
                    let key = "posts"

                    if let cached = await cache.load(key),
                       let posts = try? JSONDecoder().decode([Post].self, from: cached) {
                        await send(.postsResponse(.success(posts)))
                        return
                    }

                    await send(
                        .postsResponse(
                            TaskResult {
                                let response = try await network.send(
                                    NetworkRequest(path: "/posts")
                                )
                                await cache.save(key, response.data)
                                return try JSONDecoder().decode([Post].self, from: response.data)
                            }
                        )
                    )
                }

            // 2️⃣ Cached data arrived
            case let .cachedPostsLoaded(posts):
                state.posts = posts
                return .none

            // 3️⃣ Network success
            case let .postsResponse(.success(posts)):
                state.posts = posts
                state.isLoading = false
                return .none

            // 4️⃣ Network failure
            case let .postsResponse(.failure(error)):
                state.error = error.localizedDescription
                state.isLoading = false
                return .none
            }
        }
    }
}

enum CacheKey {
    static let posts = "home.posts"
}
