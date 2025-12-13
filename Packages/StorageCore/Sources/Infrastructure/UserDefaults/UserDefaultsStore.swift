//
//  UserDefaultsStore.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public actor UserDefaultsStore: KeyValueStore {

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func set<T: Codable & Sendable>(
        _ value: T,
        for key: StorageKey
    ) async throws {

        if let v = value as? String {
            defaults.set(v, forKey: key.rawValue); return
        }
        if let v = value as? Int {
            defaults.set(v, forKey: key.rawValue); return
        }
        if let v = value as? Bool {
            defaults.set(v, forKey: key.rawValue); return
        }
        if let v = value as? Double {
            defaults.set(v, forKey: key.rawValue); return
        }

        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key.rawValue)
        } catch {
            throw StorageError.encoding
        }
    }

    public func get<T: Codable & Sendable>(
        _ type: T.Type,
        for key: StorageKey
    ) async throws -> T {

        if T.self == String.self,
           let v = defaults.string(forKey: key.rawValue) as? T {
            return v
        }

        if T.self == Int.self {
            return defaults.integer(forKey: key.rawValue) as! T
        }

        if T.self == Bool.self {
            return defaults.bool(forKey: key.rawValue) as! T
        }

        if T.self == Double.self {
            return defaults.double(forKey: key.rawValue) as! T
        }

        guard let data = defaults.data(forKey: key.rawValue) else {
            throw StorageError.notFound
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StorageError.encoding
        }
    }

    public func remove(_ key: StorageKey) async {
        defaults.removeObject(forKey: key.rawValue)
    }

    public func exists(_ key: StorageKey) async -> Bool {
        defaults.object(forKey: key.rawValue) != nil
    }
}
