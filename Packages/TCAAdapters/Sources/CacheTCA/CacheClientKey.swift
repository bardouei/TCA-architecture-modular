//
//  CacheClientKey.swift
//  TCAAdapters
//
//  Created by baner on 12/13/25.
//

import ComposableArchitecture
import StorageCore

private enum CacheClientKey: DependencyKey {
    static let liveValue: CacheService = DiskCache()
}

public extension DependencyValues {
    var cache: CacheService {
        get { self[CacheClientKey.self] }
        set { self[CacheClientKey.self] = newValue }
    }
}
