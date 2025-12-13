//
//  StorageLoggerProtocol.swift
//  StorageCore
//
//  Created by baner on 12/13/25.
//

import Foundation

public protocol StorageLoggerProtocol: Sendable {
    func logSave(key: String)
    func logRead(key: String, hit: Bool)
    func logRemove(key: String)
}

public struct EmptyStorageLogger: StorageLoggerProtocol {
    public init() {}
    public func logSave(key: String) {}
    public func logRead(key: String, hit: Bool) {}
    public func logRemove(key: String) {}
}
