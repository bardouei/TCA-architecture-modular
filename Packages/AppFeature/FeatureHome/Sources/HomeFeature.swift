//
//  HomeFeature.swift
//  HomeFeature
//
//  Created by baner on 12/12/25.
//

import ComposableArchitecture
import Networking
import Storage

@Reducer
public struct HomeFeature {

  public init() {}

  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public var posts: [Post] = []
    public var isLoading = false
    public var error: String?

    public init() {}
  }

  // MARK: - Action
  public enum Action: Equatable {
    case onAppear
    case postsLoaded(TaskResult<[Post]>)
  }

  // MARK: - Dependencies
  @Dependency(\.networkClient) var networkClient
  @Dependency(\.cache) var cache

  // MARK: - Reducer
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {

      case .onAppear:
        state.isLoading = true
        return .run { send in
          await send(
            .postsLoaded(
              TaskResult {
                let request = NetworkRequest(path: "/posts")
                let response = try await networkClient.send(request)
                return try JSONDecoder().decode([Post].self, from: response.data)
              }
            )
          )
        }

      case let .postsLoaded(.success(posts)):
        state.posts = posts
        state.isLoading = false
        return .none

      case let .postsLoaded(.failure(error)):
        state.error = error.localizedDescription
        state.isLoading = false
        return .none
      }
    }
  }
}
