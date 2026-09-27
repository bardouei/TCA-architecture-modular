@testable import BaseCore
import Testing

struct LockIsolatedTests {
    @Test func mutatesAndReturnsAtomicState() {
        let state = LockIsolated(0)

        let updated = state.withValue {
            $0 += 1
            return $0
        }

        #expect(updated == 1)
        #expect(state.snapshot() == 1)
    }
}
