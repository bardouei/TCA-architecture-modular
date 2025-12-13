//
//  SavePreferenceUseCase.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public protocol SavePreferenceUseCase {
    func execute<T: Codable>(_ value: T, key: StorageKey) async throws
}

public final class DefaultSavePreferenceUseCase: SavePreferenceUseCase {

    private let store: KeyValueStore

    public init(store: KeyValueStore) {
        self.store = store
    }

    public func execute<T: Codable & Sendable & Sendable>(_ value: T, key: StorageKey) async throws {
        try await store.set(value, for: key)
    }
}
