//
//  InMemoryDatabaseStoreTests.swift
//  StorageCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import StorageCore

final class InMemoryDatabaseStoreTests: XCTestCase {

    func test_saveAndFetch() async throws {
        let store = InMemoryDatabaseStore()
        let entity = TestEntity(id: "1", value: 5)

        try await store.save(entity, id: "1")
        let fetched: TestEntity =
            try await store.fetch(TestEntity.self, id: "1")

        XCTAssertEqual(fetched, entity)
    }

    func test_fetch_notFound() async {
        let store = InMemoryDatabaseStore()

        await XCTAssertThrowsErrorAsync {
            let _: TestEntity =
                try await store.fetch(TestEntity.self, id: "404")
        }
    }

    func test_delete_removesEntity() async throws {
        let store = InMemoryDatabaseStore()
        let entity = TestEntity(id: "1", value: 7)

        try await store.save(entity, id: "1")
        try await store.delete(TestEntity.self, id: "1")

        await XCTAssertThrowsErrorAsync {
            let _: TestEntity =
                try await store.fetch(TestEntity.self, id: "1")
        }
    }
}
