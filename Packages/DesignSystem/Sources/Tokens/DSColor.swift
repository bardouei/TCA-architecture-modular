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
    public static let secondary = Color.gray

    #if os(iOS)
    public static let background = Color(.systemBackground)
    public static let surface = Color(.secondarySystemBackground)
    #elseif os(macOS)
    public static let background = Color(nsColor: .windowBackgroundColor)
    public static let surface = Color(nsColor: .underPageBackgroundColor)
    #else
    public static let background = Color.white
    public static let surface = Color.gray.opacity(0.1)
    #endif

    public static let error = Color.red
}
