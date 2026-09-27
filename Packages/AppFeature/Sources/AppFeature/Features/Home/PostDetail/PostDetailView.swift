//
//  PostDetailView.swift
//  AppFeature
//
//  Created by baner on 12/17/25.
//

import SwiftUI
import ComposableArchitecture

public struct PostDetailView: View {

    let store: StoreOf<PostDetail>

    public init(store: StoreOf<PostDetail>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(store.post.title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(store.post.body)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Post")
    }
}
