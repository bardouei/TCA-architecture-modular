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
        guard let storedValue = defaults.object(forKey: key.rawValue) else {
            throw StorageError.notFound
        }

        if T.self == String.self,
           let v = storedValue as? T {
            return v
        }

        if T.self == Int.self, let value = storedValue as? Int, let typed = value as? T {
            return typed
        }

        if T.self == Bool.self, let value = storedValue as? Bool, let typed = value as? T {
            return typed
        }

        if T.self == Double.self, let value = storedValue as? Double, let typed = value as? T {
            return typed
        }

        guard let data = storedValue as? Data else {
            throw StorageError.decoding
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StorageError.decoding
        }
    }

    public func remove(_ key: StorageKey) async {
        defaults.removeObject(forKey: key.rawValue)
    }

    public func exists(_ key: StorageKey) async -> Bool {
        defaults.object(forKey: key.rawValue) != nil
    }
}
