# DesignSystem

DesignSystem defines the application's shared visual language. It contains foundation tokens, reusable layouts, and SwiftUI components, with no feature or business-logic dependency.

## Tokens

- `DSColor`: primary, secondary, semantic status colors, background, surface, text, and separator colors.
- `DSTypography`: semantic text styles that support Dynamic Type.
- `DSSpacing`: shared spacing scale.
- `DSRadius`: shared corner-radius scale.

## Components

- `DSButton`: primary, secondary, destructive, icon, disabled, and loading presentation.
- `DSCard`: standard surface, padding, radius, and shadow.
- `DSBadge`: info, success, warning, and error status.
- `DSSectionHeader`: icon, title, and optional subtitle.
- `DSLoadingView` and `DSEmptyStateView`: shared state presentation.
- `DSContainer`: standard screen padding and background.

```swift
DSContainer {
    VStack(spacing: DSSpacing.md) {
        DSSectionHeader("Account", systemImage: "person")
        DSCard { Text("Content").font(DSTypography.body) }
        DSBadge("Ready", kind: .success)
        DSButton("Continue", systemImage: "arrow.right") { }
    }
}
```

Semantic platform colors automatically adapt to light and dark appearance. Use text styles for Dynamic Type, real `Button` controls for interactions, and accessible labels for icon-only controls.
