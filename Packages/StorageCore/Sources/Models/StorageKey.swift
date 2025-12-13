//
//  StorageKey.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public struct StorageKey: Hashable, Sendable {
    public let rawValue: String
    public init(_ rawValue: String) { self.rawValue = rawValue }
}

public enum StorageKeys {
    public enum Auth {
        public static let token = StorageKey("auth.token")
    }
}
