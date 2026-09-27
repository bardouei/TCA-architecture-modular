import Foundation

public actor DiskCache: CacheService {
    private let directory: URL
    private let logger: StorageLoggerProtocol

    public init(
        directory: URL? = nil,
        logger: StorageLoggerProtocol = EmptyStorageLogger()
    ) {
        self.directory = directory
            ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.logger = logger
    }

    public func load(_ key: String) async throws -> Data? {
        let url = try fileURL(for: key)
        let data: Data?

        do {
            data = try await Task.detached {
                try Data(contentsOf: url)
            }.value
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            data = nil
        } catch {
            throw StorageError.underlying("Disk cache read failed: \(error)")
        }

        logger.logRead(key: key, hit: data != nil)
        return data
    }

    public func save(_ key: String, _ data: Data) async throws {
        let url = try fileURL(for: key)

        do {
            try await Task.detached {
                try FileManager.default.createDirectory(
                    at: url.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try data.write(to: url, options: .atomic)
            }.value
            logger.logSave(key: key)
        } catch {
            throw StorageError.underlying("Disk cache save failed: \(error)")
        }
    }

    public func remove(_ key: String) async throws {
        let url = try fileURL(for: key)

        do {
            try await Task.detached {
                guard FileManager.default.fileExists(atPath: url.path) else { return }
                try FileManager.default.removeItem(at: url)
            }.value
        } catch {
            throw StorageError.underlying("Disk cache remove failed: \(error)")
        }

        logger.logRemove(key: key)
    }

    private func fileURL(for key: String) throws -> URL {
        guard !key.isEmpty else {
            throw StorageError.invalidKey
        }

        let encoded = Data(key.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")

        return directory.appendingPathComponent(encoded, isDirectory: false)
    }
}
