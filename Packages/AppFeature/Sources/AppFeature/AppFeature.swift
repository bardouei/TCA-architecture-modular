//
//  AppFeature.swift
//  AppFeature
//
//  Created by baner on 12/1
//

import ComposableArchitecture
import FeatureSplash
import FeatureHome

@Reducer
public struct AppFeature {

  public init() {}

  // MARK: - State
  @ObservableState
  public struct State: Equatable {

    public var splash: SplashFeature.State?
    public var home: HomeFeature.State?

    public init() {
      self.splash = .init()
      self.home = nil
    }
  }

  // MARK: - Action
  @CasePathable
  public enum Action {
    case splash(SplashFeature.Action)
    case home(HomeFeature.Action)
    case removeSplash
  }

  // MARK: - Reducer
  public var body: some ReducerOf<Self> {

    Reduce { state, action in
      switch action {

      case .splash(.finished):
        state.home = .init()
        return .send(.removeSplash)

      case .removeSplash:
        state.splash = nil
        return .none

      case .splash, .home:
        return .none
      }
    }
    .ifLet(\.splash, action: \.splash) {
      SplashFeature()
    }
    .ifLet(\.home, action: \.home) {
      HomeFeature()
    }
  }
}
