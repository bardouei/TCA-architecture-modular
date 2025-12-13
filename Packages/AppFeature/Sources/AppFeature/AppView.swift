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

  let store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    ZStack {

      IfLetStore(
        store.scope(state: \.splash, action: \.splash)
      ) { splashStore in
        SplashView(store: splashStore)
      }

      IfLetStore(
        store.scope(state: \.home, action: \.home)
      ) { homeStore in
        HomeView(store: homeStore)
      }
    }
  }
}
