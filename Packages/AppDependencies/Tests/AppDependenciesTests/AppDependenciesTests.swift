import XCTest
@testable import AppDependencies

final class AppDependenciesTests: XCTestCase {
    func testDiskCacheClientRoundTripAndRemove() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("AppDependenciesTests.\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let client = CacheClient.disk(directory: directory)
        let data = Data("cached".utf8)

        try await client.save("post/1", data)
        let loaded = try await client.load("post/1")
        XCTAssertEqual(loaded, data)

        try await client.remove("post/1")
        let removed = try await client.load("post/1")
        XCTAssertNil(removed)
    }
}
