import SwiftUI

public struct DSBadge: View {
    public enum Kind: Sendable, Equatable {
        case info
        case success
        case warning
        case error
    }

    private let title: String
    private let kind: Kind

    public init(_ title: String, kind: Kind = .info) {
        self.title = title
        self.kind = kind
    }

    public var body: some View {
        Text(title)
            .font(DSTypography.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(color.opacity(0.14), in: Capsule())
            .accessibilityLabel(title)
    }

    private var color: Color {
        switch kind {
        case .info: DSColor.info
        case .success: DSColor.success
        case .warning: DSColor.warning
        case .error: DSColor.error
        }
    }
}
