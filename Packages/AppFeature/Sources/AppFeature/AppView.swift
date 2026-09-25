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
import DesignSystem

public struct AppView: View {

  @Bindable var store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    switch store.scope(state: \.destination, action: \.destination).case {
      case let .splash(splashStore):
        SplashView(store: splashStore)
      case let .home(homeStore):
        MainContentView(homeStore: homeStore)
      }
  }
}

private struct MainContentView: View {
  let homeStore: StoreOf<HomeFeature>

  var body: some View {
    TabView {
      HomeView(store: homeStore)
        .tabItem { Label("Home", systemImage: "house") }

      ModuleShowcaseView()
        .tabItem { Label("Modules", systemImage: "shippingbox") }
    }
    .tint(DSColor.primary)
  }
}
