//
//  ThemeManager.swift
//  BaseCore
//
//  Created by baner on 6/22/26.
//

import SwiftUI
import Combine

@MainActor
public final class ThemeManager: ObservableObject {

    public static let shared = ThemeManager()

    @Published
    public private(set) var current: DSTheme

    private init() {
        self.current = LightTheme()
    }

    public func setTheme(_ theme: DSTheme) {
        current = theme
    }

    public func toggleTheme() {

        switch current {

        case is LightTheme:
            current = DarkTheme()

        default:
            current = LightTheme()
        }
    }
}
