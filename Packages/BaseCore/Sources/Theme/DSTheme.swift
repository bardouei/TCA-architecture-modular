//
//  DSTheme.swift
//  BaseCore
//
//  Created by baner on 6/22/26.
//

import SwiftUI

public protocol DSTheme {

    // Colors
    var primary: Color { get }
    var secondary: Color { get }

    var background: Color { get }
    var surface: Color { get }

    var textPrimary: Color { get }
    var textSecondary: Color { get }

    var error: Color { get }

    // Typography
    var titleFont: Font { get }
    var headlineFont: Font { get }
    var bodyFont: Font { get }
    var captionFont: Font { get }
}
