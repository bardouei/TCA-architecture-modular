import Foundation

/// Protects mutable value state behind one lock.
///
/// Keep related values in a single state struct so multi-property mutations remain atomic.
public final class LockIsolated<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var value: Value

    public init(_ value: consuming Value) {
        self.value = value
    }

    @discardableResult
    public func withValue<Result>(
        _ operation: (inout Value) throws -> Result
    ) rethrows -> Result {
        try lock.withLock {
            try operation(&value)
        }
    }

    public func snapshot() -> Value where Value: Sendable {
        withValue { $0 }
    }
}
