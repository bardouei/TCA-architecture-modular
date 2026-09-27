import Foundation

public protocol CacheService: Sendable {
    func load(_ key: String) async throws -> Data?
    func save(_ key: String, _ data: Data) async throws
    func remove(_ key: String) async throws
}
