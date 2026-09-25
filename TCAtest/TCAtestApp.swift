//
//  TCAtestApp.swift
//  TCAtest
//
//  Created by baner on 12/13/25.
//

import SwiftUI
import ComposableArchitecture
import AppFeature

@main
struct TCAtestApp: App {
  @AppStorage("appearance.mode") private var appearanceRawValue = AppearanceMode.system.rawValue

  private let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
        .preferredColorScheme(colorScheme)
    }
  }

  private var colorScheme: ColorScheme? {
    switch AppearanceMode(rawValue: appearanceRawValue) ?? .system {
    case .system: nil
    case .light: .light
    case .dark: .dark
    }
  }
}
