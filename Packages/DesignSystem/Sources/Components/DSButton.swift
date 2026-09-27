//
//  DSButton.swift
//  DesignSystem
//
//  Created by baner on 1/3/26.
//

import SwiftUI

public struct DSButton: View {

    public enum Style: Sendable, Equatable {
        case primary
        case secondary
        case destructive
    }

    private let title: LocalizedStringResource
    private let systemImage: String?
    private let style: Style
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        _ title: LocalizedStringResource,
        systemImage: String? = nil,
        style: Style = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
                .font(DSTypography.headline)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm + 4)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        }
        .disabled(isLoading)
        .accessibilityLabel(Text(title))
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: DSColor.primary
        case .secondary: DSColor.surface
        case .destructive: DSColor.error
        }
    }

    private var foregroundColor: Color {
        style == .secondary ? DSColor.textPrimary : .white
    }
}
