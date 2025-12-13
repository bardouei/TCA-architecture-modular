//
//  LoadPreferenceUseCase.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public protocol LoadPreferenceUseCase {
    func execute<T: Codable>(_ type: T.Type, key: StorageKey) async throws -> T
}

public final class DefaultLoadPreferenceUseCase: LoadPreferenceUseCase {

    private let store: KeyValueStore

    public init(store: KeyValueStore) {
        self.store = store
    }

    public func execute<T: Codable & Sendable & Sendable>(_ type: T.Type, key: StorageKey) async throws -> T {
        try await store.get(type, for: key)
    }
}
