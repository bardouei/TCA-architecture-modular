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

struct AppClipPostClient: Sendable {
    var fetchPost: @Sendable (Int) async throws -> EntityPost
}

private enum AppClipPostClientKey: DependencyKey {
    static let liveValue = AppClipPostClient { id in
        let request = NetworkRequest(path: "/posts/\(id)")
        let response = try await AnyNetworkClient.live.send(request)
        return try JSONDecoder().decode(EntityPost.self, from: response.data)
    }

    static let testValue = AppClipPostClient { _ in
        throw NetworkError.invalidRequest
    }
}

extension DependencyValues {
    var appClipPostClient: AppClipPostClient {
        get { self[AppClipPostClientKey.self] }
        set { self[AppClipPostClientKey.self] = newValue }
    }
}

@Reducer
struct AppClipFeature {
    @ObservableState
    struct State: Equatable {
        let postId: Int
        var post: EntityPost?
        var isLoading = false
        var error: String?
    }
    
    enum Action: Equatable {
        case onAppear
        case postResponse(TaskResult<EntityPost>)
    }
    
    @Dependency(\.appClipPostClient) var postClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.error = nil
                let id = state.postId
                let postClient = self.postClient

                return .run { send in
                    await send(
                        .postResponse(
                            TaskResult {
                                try await postClient.fetchPost(id)
                            }
                        )
                    )
                }

            case let .postResponse(.success(post)):
                state.post = post
                state.isLoading = false
                state.error = nil
                return .none

            case let .postResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
            }
        }
    }
}
