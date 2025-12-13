//
//  KeyStorageProtocol.swift
//  Storage
//
//  Created by baner on 12/9/25.
//

import Foundation

public protocol SecureStore: Sendable {
    func save(_ data: Data, for key: StorageKey) async throws
    func load(for key: StorageKey) async throws -> Data
    func delete(for key: StorageKey) async throws
    func exists(_ key: StorageKey) async -> Bool
}
