//
//  CacheService.swift
//  StorageCore
//
//  Created by baner on 12/13/25.
//

import Foundation

public protocol CacheService: Sendable {
    func load(_ key: String) async -> Data?
    func save(_ key: String, _ data: Data) async
    func remove(_ key: String) async
}

public actor DiskCache: CacheService {

    private let directory: URL
    private let logger: StorageLoggerProtocol

    public init(
        directory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0],
        logger: StorageLoggerProtocol = EmptyStorageLogger()
    ) {
        self.directory = directory
        self.logger = logger
    }

    public func load(_ key: String) async -> Data? {
        let url = directory.appendingPathComponent(key)

        let data = try? Data(contentsOf: url)
        logger.logRead(key: key, hit: data != nil)

        return data
    }

    public func save(_ key: String, _ data: Data) async {
        let url = directory.appendingPathComponent(key)

        do {
            try data.write(to: url)
            logger.logSave(key: key)
        } catch {
            
        }
    }

    public func remove(_ key: String) async {
        let url = directory.appendingPathComponent(key)
        try? FileManager.default.removeItem(at: url)
        logger.logRemove(key: key)
    }
}
