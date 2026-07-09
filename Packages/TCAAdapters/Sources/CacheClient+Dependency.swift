//
//  CacheClient+Dependency.swift
//  TCAAdapters
//
//  Created by baner on 1/3/26.
//

import Foundation
import ComposableArchitecture

public struct CacheClient : Sendable {
    public var load: @Sendable (String) async -> Data?
    public var save: @Sendable (String, Data) async -> Void
    
    public init(
        load: @escaping @Sendable (String) async -> Data?,
        save: @escaping @Sendable (String, Data) async -> Void
    ) {
        self.load = load
        self.save = save
    }
}

private enum CacheClientKey: DependencyKey {
    static let liveValue = CacheClient(
        load: { _ in nil },
        save: { _, _ in }
    )
}

public extension DependencyValues {
    var cache: CacheClient {
        get { self[CacheClientKey.self] }
        set { self[CacheClientKey.self] = newValue }
    }
}
