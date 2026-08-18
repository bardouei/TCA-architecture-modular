//
//  HomeFeature.swift
//  HomeFeature
//
//  Created by baner on 12/12/25.
//

import Foundation
import DomainCore
import PostDetailFeature
import ComposableArchitecture

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

    private enum CancelID {
        case loadPosts
    }
    
    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .onAppear:
            state.isLoading = true
            state.error = nil
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
            state.error = nil
            return .none

        case let .postsResponse(.failure(error)):
            state.isLoading = false
            state.error = error.localizedDescription
            return .none
            
        case let .postTapped(post):
            state.path.append(
                .postDetail(
                    PostDetailFeature.State(post: post)
                )
            )
            return .none
            
        case .path:
            return .none
        }
    }
}
