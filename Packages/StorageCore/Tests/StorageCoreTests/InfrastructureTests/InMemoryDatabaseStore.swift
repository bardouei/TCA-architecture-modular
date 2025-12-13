//
//  InMemoryDatabaseStore.swift
//  StorageCore
//
//  Created by baner on 12/12/25.
//

import Foundation
@testable import StorageCore

public actor InMemoryDatabaseStore: DatabaseStore {

    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init() {}

    public func save<T: Codable & Sendable>(_ object: T, id: String) async throws {
        storage[id] = try encoder.encode(object)
    }

    public func fetch<T: Codable & Sendable>(_ type: T.Type, id: String) async throws -> T {
        guard let data = storage[id] else {
            throw StorageError.notFound
        }
        return try decoder.decode(T.self, from: data)
    }

    public func delete<T: Sendable>(_ type: T.Type, id: String) async throws {
        storage.removeValue(forKey: id)
    }
}
