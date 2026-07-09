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
    var body: some Scene {
        WindowGroup {
            AppClipView(
                store: Store(
                    initialState: AppClipFeature.State(postId: 2),
                    reducer: { AppClipFeature() }
                )
            )
        }
    }
}
