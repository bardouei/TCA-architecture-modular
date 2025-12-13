//
//  HomeView.swift
//  FeatureHome
//
//  Created by baner on 12/12/25.
//

import SwiftUI
import ComposableArchitecture

public struct HomeView: View {

  let store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    List {
      ForEach(store.posts) { post in
        VStack(alignment: .leading) {
          Text(post.title).bold()
          Text(post.body).font(.caption)
        }
      }
    }
    .overlay {
      if store.isLoading {
        ProgressView()
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}
