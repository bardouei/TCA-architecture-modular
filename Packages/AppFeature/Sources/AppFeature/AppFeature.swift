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

    public var destination: Destination.State

    public init() {
      self.destination = .splash(.init())
    }
  }

  @Reducer
  public enum Destination {
    case splash(SplashFeature)
    case home(HomeFeature)
  }

  // MARK: - Action
  @CasePathable
  public enum Action {
    case destination(Destination.Action)
  }

  // MARK: - Reducer
  public var body: some ReducerOf<Self> {
    Scope(state: \.destination, action: \.destination) {
      Destination.body
    }
    Reduce { state, action in
      switch action {

      case .destination(.splash(.finished)):
        state.destination = .home(.init())
        return .none

      case .destination:
        return .none
      }
    }
  }
}

extension AppFeature.Destination.State: Equatable {}
