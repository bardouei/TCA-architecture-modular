//
//  HomeFeature.swift
//  HomeFeature
//
//  Created by baner on 12/12/25.
//

import Foundation
import NetworkCore
import DomainCore
import PostDetailFeature
import ComposableArchitecture
import TCAAdapters

@Reducer
public struct HomeFeature {

    @Dependency(\.networkClient) var networkClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce(core)
            .forEach(\.path, action: \.path)
    }
}

extension HomeFeature {
    
    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
            
        case .onAppear:
            let networkClient = self.networkClient
            
            return .run { send in
                do {
                    let response = try await networkClient.send(
                        NetworkRequest(path: "/posts")
                    )
                    
                    let posts = try JSONDecoder().decode(
                        [EntityPost].self,
                        from: response.data
                    )
                    
                    await send(.postsLoaded(posts))
                } catch {
                    print("❌ Network error:", error)
                }
            }
            
        case let .postsLoaded(posts):
            state.posts = posts
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
