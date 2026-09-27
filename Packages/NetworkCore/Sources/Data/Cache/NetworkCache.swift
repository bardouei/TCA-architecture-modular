import CryptoKit
import Foundation

public actor NetworkCache {
    public enum CachePolicy: Sendable, Equatable {
        case noCache
        case memoryOnly
        case memoryAndDisk
    }

    public struct CacheEntry: Sendable {
        public let data: Data
        public let response: NetworkResponse
        public let timestamp: Date

        public init(data: Data, response: NetworkResponse, timestamp: Date = Date()) {
            self.data = data
            self.response = response
            self.timestamp = timestamp
        }
    }

    private struct StoredEntry: Codable, Sendable {
        let data: Data
        let statusCode: Int
        let headers: [String: String]
        let timestamp: Date
    }

    private let memoryCache = NSCache<NSString, NSData>()
    private let defaultExpiration: TimeInterval?
    private let diskDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        memoryCapacity: Int = 10 * 1024 * 1024,
        defaultExpiration: TimeInterval? = 300,
        diskDirectory: URL? = nil
    ) {
        memoryCache.totalCostLimit = memoryCapacity
        self.defaultExpiration = defaultExpiration
        self.diskDirectory = diskDirectory
            ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
                .appending(path: "NetworkCore", directoryHint: .isDirectory)
            ?? FileManager.default.temporaryDirectory
                .appending(path: "NetworkCore", directoryHint: .isDirectory)
    }

    public func store(
        _ response: NetworkResponse,
        for request: NetworkRequest,
        policy: CachePolicy = .memoryOnly
    ) async {
        guard policy != .noCache else { return }

        let key = cacheKey(for: request)
        let storedEntry = StoredEntry(
            data: response.data,
            statusCode: response.statusCode,
            headers: response.headers,
            timestamp: Date()
        )

        guard let encoded = try? encoder.encode(storedEntry) else { return }
        memoryCache.setObject(encoded as NSData, forKey: key as NSString, cost: encoded.count)

        guard policy == .memoryAndDisk else { return }
        let fileURL = diskURL(for: key)
        try? await Task.detached {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try encoded.write(
                to: fileURL,
                options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
            )
        }.value
    }

    public func retrieve(for request: NetworkRequest) async -> CacheEntry? {
        let key = cacheKey(for: request)

        if let data = memoryCache.object(forKey: key as NSString) as Data?,
           let entry = decodeValidEntry(data, key: key) {
            return makeCacheEntry(entry, request: request)
        }

        let fileURL = diskURL(for: key)
        guard let data = try? await Task.detached(operation: {
            try Data(contentsOf: fileURL)
        }).value,
        let entry = decodeValidEntry(data, key: key) else {
            return nil
        }

        memoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
        return makeCacheEntry(entry, request: request)
    }

    public func remove(for request: NetworkRequest) async {
        let key = cacheKey(for: request)
        memoryCache.removeObject(forKey: key as NSString)
        let fileURL = diskURL(for: key)
        try? await Task.detached {
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
            try FileManager.default.removeItem(at: fileURL)
        }.value
    }

    public func clear() {
        memoryCache.removeAllObjects()
        try? FileManager.default.removeItem(at: diskDirectory)
    }

    private func decodeValidEntry(_ data: Data, key: String) -> StoredEntry? {
        guard let entry = try? decoder.decode(StoredEntry.self, from: data) else {
            memoryCache.removeObject(forKey: key as NSString)
            try? FileManager.default.removeItem(at: diskURL(for: key))
            return nil
        }

        if let defaultExpiration,
           Date().timeIntervalSince(entry.timestamp) > defaultExpiration {
            memoryCache.removeObject(forKey: key as NSString)
            try? FileManager.default.removeItem(at: diskURL(for: key))
            return nil
        }
        return entry
    }

    private func makeCacheEntry(_ entry: StoredEntry, request: NetworkRequest) -> CacheEntry {
        CacheEntry(
            data: entry.data,
            response: NetworkResponse(
                request: request,
                statusCode: entry.statusCode,
                data: entry.data,
                headers: entry.headers
            ),
            timestamp: entry.timestamp
        )
    }

    private func cacheKey(for request: NetworkRequest) -> String {
        var components = [
            request.method.rawValue,
            request.baseURL?.absoluteString ?? "",
            request.path
        ]
        if let parameters = request.queryParameters {
            components.append(
                parameters.sorted { $0.key < $1.key }
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: "&")
            )
        }
        if let body = request.body {
            components.append(SHA256.hash(data: body).hexString)
        }
        return SHA256.hash(data: Data(components.joined(separator: "|").utf8)).hexString
    }

    private func diskURL(for key: String) -> URL {
        diskDirectory.appending(path: key, directoryHint: .notDirectory)
    }
}

private extension SHA256.Digest {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
