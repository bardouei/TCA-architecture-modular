//
//  PreferencesStorageProtocol.swift
//  Storage
//
//  Created by baner on 12/9/25.
//

import Foundation

public protocol KeyValueStore: Sendable {
    func set<T: Codable & Sendable>(_ value: T, for key: StorageKey) async throws
    func get<T: Codable & Sendable>(_ type: T.Type, for key: StorageKey) async throws -> T
    func remove(_ key: StorageKey) async
    func exists(_ key: StorageKey) async -> Bool
}
