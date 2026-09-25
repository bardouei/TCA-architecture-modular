import XCTest
@testable import StorageCore

final class DiskCacheTests: XCTestCase {
    func test_keyCannotEscapeCacheDirectory() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DiskCacheTests.\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = DiskCache(directory: directory)
        let data = Data("value".utf8)

        try await cache.save("../outside/file", data)

        let loadedData = try await cache.load("../outside/file")
        XCTAssertEqual(loadedData, data)
        XCTAssertFalse(FileManager.default.fileExists(
            atPath: directory.deletingLastPathComponent().appendingPathComponent("outside/file").path
        ))
    }

    func test_emptyKeyIsRejected() async {
        let cache = DiskCache(directory: FileManager.default.temporaryDirectory)
        do {
            try await cache.save("", Data())
            XCTFail("Expected invalidKey")
        } catch let error as StorageError {
            XCTAssertEqual(error, .invalidKey)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
