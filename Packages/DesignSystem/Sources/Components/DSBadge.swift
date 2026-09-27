import SwiftUI

public struct DSBadge: View {
    public enum Kind: Sendable, Equatable {
        case info
        case success
        case warning
        case error
    }

    private let label: Text
    private let kind: Kind

    public init(_ title: LocalizedStringResource, kind: Kind = .info) {
        self.label = Text(title)
        self.kind = kind
    }

    /// Creates a badge for server-provided or user-provided content that must not
    /// be interpreted as a localization key.
    public init(verbatim title: String, kind: Kind = .info) {
        self.label = Text(verbatim: title)
        self.kind = kind
    }

    public var body: some View {
        label
            .font(DSTypography.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(color.opacity(0.14), in: Capsule())
            .accessibilityLabel(label)
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
