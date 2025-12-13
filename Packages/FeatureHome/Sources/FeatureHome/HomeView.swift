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
    ZStack {

      List {
        ForEach(store.posts) { post in
          VStack(alignment: .leading, spacing: 6) {
            Text(post.title)
              .font(.headline)

            Text(post.body)
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          .padding(.vertical, 8)
        }
      }
      .listStyle(.plain)

      if store.isLoading {
        ProgressView()
      }
    }
    .navigationTitle("Posts")
    .onAppear {
      store.send(.onAppear)
    }
    .alert(
      "Error",
      isPresented: .constant(store.error != nil),
      actions: {
        Button("OK") {}
      },
      message: {
        Text(store.error ?? "")
      }
    )
  }
}
