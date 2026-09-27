import SwiftUI

public struct DSSectionHeader: View {
    private let title: LocalizedStringResource
    private let subtitle: LocalizedStringResource?
    private let systemImage: String

    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, systemImage: String) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: systemImage)
                .font(DSTypography.title3)
                .foregroundStyle(DSColor.primary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(title)
                    .font(DSTypography.title3)
                    .foregroundStyle(DSColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(DSTypography.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
