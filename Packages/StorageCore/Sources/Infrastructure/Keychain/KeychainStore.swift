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
        let query = KeychainQuery(service: service, account: key.rawValue).base
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        if updateStatus == errSecSuccess {
            return
        }
        guard updateStatus == errSecItemNotFound else {
            throw StorageError.underlying("Keychain update error: \(updateStatus)")
        }

        var addQuery = query
        attributes.forEach { addQuery[$0.key] = $0.value }
        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw StorageError.underlying("Keychain add error: \(addStatus)")
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
