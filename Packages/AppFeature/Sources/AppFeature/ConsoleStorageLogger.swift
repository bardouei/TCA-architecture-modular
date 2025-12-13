//
//  ConsoleStorageLogger.swift
//  AppFeature
//
//  Created by baner on 12/13/25.
//

import StorageCore

public struct ConsoleStorageLogger: StorageLoggerProtocol {

    public init() {}

    public func logSave(key: String) {
        print("💾 Cache SAVE key=\(key)")
    }

    public func logRead(key: String, hit: Bool) {
        if hit {
            print("📦 Cache HIT key=\(key)")
        } else {
            print("❌ Cache MISS key=\(key)")
        }
    }

    public func logRemove(key: String) {
        print("🗑 Cache REMOVE key=\(key)")
    }
}
