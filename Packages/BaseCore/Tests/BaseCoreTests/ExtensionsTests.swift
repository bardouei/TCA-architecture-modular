import Foundation
@testable import BaseCore
import Testing

struct ExtensionsTests {
    @Test func stringTrimmingAndCollectionHelpers() {
        #expect("  value\n".trimmed() == "value")
        #expect([1].isNotEmpty)
        #expect([Int]().isNotEmpty == false)
        #expect([10, 20][safe: 1] == 20)
        #expect([10, 20][safe: 2] == nil)
    }

    @Test func optionalHelpersReportPresence() {
        let value: Int? = 1
        let missing: Int? = nil

        #expect(value.isNotNil)
        #expect(missing.isNil)
    }

    @Test func timestampUsesUnixEpoch() {
        #expect(Date.nowTimestamp > 0)
    }
}
