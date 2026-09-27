//
//  CacheClient+Dependency.swift
//  AppDependencies
//
//  Created by baner on 1/3/26.
//

import Foundation
import ComposableArchitecture
import StorageCore

public struct CacheClient : Sendable {
    public var load: @Sendable (String) async throws -> Data?
    public var save: @Sendable (String, Data) async throws -> Void
    public var remove: @Sendable (String) async throws -> Void
    
    public init(
        load: @escaping @Sendable (String) async throws -> Data?,
        save: @escaping @Sendable (String, Data) async throws -> Void,
        remove: @escaping @Sendable (String) async throws -> Void
    ) {
        self.load = load
        self.save = save
        self.remove = remove
    }

    public static func disk(directory: URL? = nil) -> Self {
        let cache = DiskCache(directory: directory)
        return Self(
            load: { try await cache.load($0) },
            save: { try await cache.save($0, $1) },
            remove: { try await cache.remove($0) }
        )
    }
}

private enum CacheClientKey: DependencyKey {
    static let liveValue = CacheClient.disk()
    static let testValue = CacheClient(
        load: { _ in nil },
        save: { _, _ in },
        remove: { _ in }
    )
}

public extension DependencyValues {
    var cache: CacheClient {
        get { self[CacheClientKey.self] }
        set { self[CacheClientKey.self] = newValue }
    }
}
