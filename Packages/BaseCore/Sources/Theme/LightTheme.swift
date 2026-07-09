//
//  LightTheme.swift
//  BaseCore
//
//  Created by baner on 6/22/26.
//

import SwiftUI

public struct LightTheme: DSTheme {

    public init() {}

    // MARK: Colors

    public let primary = Color.blue
    public let secondary = Color.gray

    public let background = Color.white
    public let surface = Color(.secondarySystemBackground)

    public let textPrimary = Color.black
    public let textSecondary = Color.gray

    public let error = Color.red

    // MARK: Typography

    public let titleFont = Font.system(size: 22, weight: .bold)

    public let headlineFont = Font.system(size: 17, weight: .semibold)

    public let bodyFont = Font.system(size: 15)

    public let captionFont = Font.system(size: 13)
}
