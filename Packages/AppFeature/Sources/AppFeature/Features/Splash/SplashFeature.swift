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

  @Dependency(\.continuousClock) var clock

  public init() {}

  @ObservableState
  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case onDisappear
    case finished
  }

  private nonisolated enum CancelID: Hashable, Sendable {
    case timer
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {

      case .onAppear:
        let clock = self.clock
        return .run { send in
          try await clock.sleep(for: .seconds(2))
          await send(.finished)
        }
        .cancellable(id: CancelID.timer, cancelInFlight: true)

      case .onDisappear:
        return .cancel(id: CancelID.timer)

      case .finished:
        return .none
      }
    }
  }
}
