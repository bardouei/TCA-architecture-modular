import Testing
@testable import DesignSystem

@Suite("Design system foundations")
struct DesignSystemTests {
    @Test("Spacing scale is positive and strictly increasing")
    func spacingScale() {
        #expect(DSSpacing.xs > 0)
        #expect(DSSpacing.xs < DSSpacing.sm)
        #expect(DSSpacing.sm < DSSpacing.md)
        #expect(DSSpacing.md < DSSpacing.lg)
    }

    @Test("Radius scale is positive and ordered")
    func radiusScale() {
        #expect(DSRadius.sm > 0)
        #expect(DSRadius.sm < DSRadius.md)
        #expect(DSRadius.md < DSRadius.lg)
    }

    @Test("Button styles remain distinct")
    func buttonStyles() {
        #expect(DSButton.Style.primary != .secondary)
        #expect(DSButton.Style.secondary != .destructive)
    }

    @Test("Badge kinds remain distinct")
    func badgeKinds() {
        #expect(DSBadge.Kind.info != .success)
        #expect(DSBadge.Kind.warning != .error)
    }
}
