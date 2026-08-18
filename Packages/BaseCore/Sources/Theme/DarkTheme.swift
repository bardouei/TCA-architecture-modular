//
//  DarkTheme.swift
//  BaseCore
//
//  Created by baner on 6/22/26.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct DarkTheme: DSTheme {

    public init() {}

    // MARK: Colors

    public let primary = Color.blue
    public let secondary = Color.gray

    public let background = Color.black
    #if os(iOS)
    public let surface = Color(.systemGray6)
    #elseif os(macOS)
    public let surface = Color(nsColor: .controlBackgroundColor)
    #else
    public let surface = Color.gray.opacity(0.2)
    #endif

    public let textPrimary = Color.white
    public let textSecondary = Color.gray

    public let error = Color.red

    // MARK: Typography

    public let titleFont = Font.system(size: 22, weight: .bold)

    public let headlineFont = Font.system(size: 17, weight: .semibold)

    public let bodyFont = Font.system(size: 15)

    public let captionFont = Font.system(size: 13)
}
