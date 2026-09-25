//
//  Tokens.swift
//  DesignSystem
//
//  Created by baner on 1/3/26.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public enum DSColor {
    public static let primary = Color.blue
    public static let secondary = Color.indigo
    public static let success = Color.green
    public static let warning = Color.orange
    public static let error = Color.red
    public static let info = Color.cyan

    #if os(iOS)
    public static let background = Color(.systemBackground)
    public static let surface = Color(.secondarySystemBackground)
    public static let textPrimary = Color(.label)
    public static let textSecondary = Color(.secondaryLabel)
    public static let separator = Color(.separator)
    #elseif os(macOS)
    public static let background = Color(nsColor: .windowBackgroundColor)
    public static let surface = Color(nsColor: .underPageBackgroundColor)
    public static let textPrimary = Color(nsColor: .labelColor)
    public static let textSecondary = Color(nsColor: .secondaryLabelColor)
    public static let separator = Color(nsColor: .separatorColor)
    #else
    public static let background = Color.white
    public static let surface = Color.gray.opacity(0.1)
    public static let textPrimary = Color.primary
    public static let textSecondary = Color.secondary
    public static let separator = Color.gray.opacity(0.3)
    #endif

}
