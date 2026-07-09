//
//  AppClipFeature.swift
//  TCAtest
//
//  Created by baner on 2/1/26.
//

import ComposableArchitecture
import Foundation
import DomainCore
import NetworkCore
import TCAAdapters

@Reducer
struct AppClipFeature {
    @ObservableState
    struct State: Equatable {
        let postId: Int
        var post: EntityPost?
        var isLoading = false
    }
    
    enum Action: Equatable {
        case onAppear
        case postResponse(TaskResult<EntityPost>)
    }
    
    @Dependency(\.networkClient) var network
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                let id = state.postId

                return .run { send in
                    await send(
                        .postResponse(
                            TaskResult {
                                let request = NetworkRequest(path: "/posts/\(id)")
                                let response = try await network.send(request)
                                return try JSONDecoder().decode(
                                    EntityPost.self,
                                    from: response.data
                                )
                            }
                        )
                    )
                }

            case let .postResponse(.success(post)):
                state.post = post
                state.isLoading = false
                return .none

            case .postResponse(.failure):
                state.isLoading = false
                return .none
            }
        }
    }
}
