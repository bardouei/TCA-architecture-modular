//
//  HomeFeature.swift
//  HomeFeature
//
//  Created by baner on 12/12/25.
//

import Foundation
import DomainCore
import ComposableArchitecture
import NetworkCore

@Reducer
public struct HomeFeature {

    @Dependency(\.postsClient) var postsClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce(core)
            .forEach(\.path, action: \.path)
    }
}

extension HomeFeature {

    private nonisolated enum CancelID: Hashable, Sendable {
        case loadPosts
    }
    
    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .task, .refresh, .retryTapped:
            state.isLoading = true
            state.failure = nil
            let postsClient = self.postsClient
            
            return .run { send in
                await send(.postsResponse(TaskResult {
                    try await postsClient.fetchPosts()
                }))
            }
            .cancellable(id: CancelID.loadPosts, cancelInFlight: true)
            
        case let .postsResponse(.success(posts)):
            state.isLoading = false
            state.posts = posts
            state.failure = nil
            return .none

        case let .postsResponse(.failure(error)):
            state.isLoading = false
            state.failure = loadFailure(for: error)
            return .none

        case .cancelLoading:
            state.isLoading = false
            return .cancel(id: CancelID.loadPosts)
            
        case let .postTapped(post):
            state.path.append(
                .postDetail(
                    PostDetail.State(post: post)
                )
            )
            return .none
            
        case .path:
            return .none
        }
    }

    private func loadFailure(for error: Error) -> LoadFailure {
        if error is DecodingError { return .invalidData }
        guard let networkError = error as? NetworkError else { return .unavailable }
        return networkError.isConnectionError ? .connection : .unavailable
    }
}
