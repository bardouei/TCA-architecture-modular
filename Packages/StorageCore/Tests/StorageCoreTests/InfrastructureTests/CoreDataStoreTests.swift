import XCTest
@testable import StorageCore

final class CoreDataStoreTests: XCTestCase {
    private struct Record: Codable, Sendable, Equatable {
        let title: String
    }

    func test_saveFetchAndDeleteUsingPackagedModel() async throws {
        let stack = try await CoreDataStack(modelName: "CoreDataModel", inMemory: true)
        let store = CoreDataStore(stack: stack)
        let record = Record(title: "Persisted")

        try await store.save(record, id: "record-1")
        let fetched = try await store.fetch(Record.self, id: "record-1")
        XCTAssertEqual(fetched, record)

        try await store.delete(Record.self, id: "record-1")
        do {
            let _: Record = try await store.fetch(Record.self, id: "record-1")
            XCTFail("Expected deleted record to be missing")
        } catch let error as StorageError {
            XCTAssertEqual(error, .notFound)
        }
    }
}
