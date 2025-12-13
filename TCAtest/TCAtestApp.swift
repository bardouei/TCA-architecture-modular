//
//  TCAtestApp.swift
//  TCAtest
//
//  Created by baner on 12/13/25.
//

import SwiftUI
import ComposableArchitecture
import AppFeature
import TCAAdapters
import StorageCore

@main
struct TCAtestApp: App {
    
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: AppFeature.State()
        ) {
          AppFeature()
        }
      )
    }
  }
}
