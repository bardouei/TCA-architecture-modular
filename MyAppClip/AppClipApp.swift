//
//  AppClipApp.swift
//  TCAtest
//
//  Created by baner on 2/1/26.
//

import SwiftUI
import ComposableArchitecture
import AppClipFeature

@main
struct AppClipApp: App {
    private let store = Store(
        initialState: AppClipFeature.State(postId: 2),
        reducer: { AppClipFeature() }
    )

    var body: some Scene {
        WindowGroup {
            AppClipView(store: store)
        }
    }
}
