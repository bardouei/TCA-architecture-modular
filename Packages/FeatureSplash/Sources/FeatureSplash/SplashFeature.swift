//
//  SplashFeature.swift
//  FeatureSplash
//
//  Created by baner on 12/12/25.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct SplashFeature {

  public init() {}

  @ObservableState
  public struct State {
    public init() {}
  }

  public enum Action {
    case onAppear
    case finished
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {

      case .onAppear:
        return .run { send in
          try await Task.sleep(for: .seconds(2))
          await send(.finished)
        }

      case .finished:
        return .none
      }
    }
  }
}
