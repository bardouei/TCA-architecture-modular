//
//  KeychainStore.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation
import Security

public actor KeychainStore: SecureStore {

    private let service: String

    public init(service: String = Bundle.main.bundleIdentifier ?? "App") {
        self.service = service
    }

    // MARK: - SecureStore (Domain API)

    public func save(_ data: Data, for key: StorageKey) async throws {
        try await set(data, for: key)
    }

    public func load(for key: StorageKey) async throws -> Data {
        try await getData(for: key)
    }

    public func delete(for key: StorageKey) async throws {
        try await remove(key)
    }

    public func exists(_ key: StorageKey) async -> Bool {
        do {
            _ = try await getData(for: key)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Internal Keychain implementation (unchanged)

    private func set(_ data: Data, for key: StorageKey) async throws {
        let q = KeychainQuery(service: service, account: key.rawValue)
        var query = q.base
        SecItemDelete(query as CFDictionary)

        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] =
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw StorageError.underlying("Keychain error: \(status)")
        }
    }

    private func getData(for key: StorageKey) async throws -> Data {
        let q = KeychainQuery(service: service, account: key.rawValue)
        var query = q.base
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            throw StorageError.notFound
        }

        guard status == errSecSuccess,
              let data = item as? Data else {
            throw StorageError.underlying("Keychain error: \(status)")
        }

        return data
    }

    private func remove(_ key: StorageKey) async throws {
        let q = KeychainQuery(service: service, account: key.rawValue)
        let status = SecItemDelete(q.base as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw StorageError.underlying("Keychain error: \(status)")
        }
    }
}
