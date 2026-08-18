//
//  AppView.swift
//  AppFeature
//
//  Created by baner on 12/12/25.
//

import SwiftUI
import ComposableArchitecture
import FeatureSplash
import FeatureHome

public struct AppView: View {

  @Bindable var store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    ZStack {

      if let splashStore = store.scope(state: \.splash, action: \.splash) {
        SplashView(store: splashStore)
      }

      if let homeStore = store.scope(state: \.home, action: \.home) {
        HomeView(store: homeStore)
      }
    }
  }
}
