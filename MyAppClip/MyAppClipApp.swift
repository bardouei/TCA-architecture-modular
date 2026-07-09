//
//  MyAppClipApp.swift
//  MyAppClip
//
//  Created by baner on 2/1/26.
//

import SwiftUI
import ComposableArchitecture
import DomainCore

struct AppClipView: View {

    let store: StoreOf<AppClipFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.isLoading {
                    ProgressView()
                } else if let post = viewStore.post {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(post.title)
                            .font(.title2)
                        Text(post.body)
                            .font(.body)
                    }
                    .padding()
                } else {
                    Text("No data")
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
