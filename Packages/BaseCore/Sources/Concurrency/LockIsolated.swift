//
//  LockIsolated.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

import Foundation

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
