//
//  AppClipApp.swift
//  TCAtest
//
//  Created by baner on 2/1/26.
//

import SwiftUI
import ComposableArchitecture

@main
struct AppClipApp: App {
    private let store = Store(
        initialState: ClipRootFeature.State(postId: 2),
        reducer: { ClipRootFeature() }
    )

    var body: some Scene {
        WindowGroup {
            AppClipView(store: store)
        }
    }
}
