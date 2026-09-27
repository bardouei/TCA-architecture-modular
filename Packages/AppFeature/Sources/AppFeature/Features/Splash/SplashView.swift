//
//  SplashView.swift
//  FeatureSplash
//
//  Created by baner on 12/12/25.
//

import SwiftUI
import ComposableArchitecture

public struct SplashView: View {

  let store: StoreOf<SplashFeature>

  public init(store: StoreOf<SplashFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack {
      ProgressView()
      Text("Loading...")
    }
    .task {
      await store.send(.onAppear).finish()
    }
  }
}
