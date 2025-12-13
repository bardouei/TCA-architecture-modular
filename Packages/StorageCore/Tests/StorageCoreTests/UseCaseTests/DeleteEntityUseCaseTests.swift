//
//  DeleteEntityUseCaseTests.swift
//  StorageCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import StorageCore

struct TestEntity: Codable, Sendable, Equatable {
    let id: String
    let value: Int
}

final class DeleteEntityUseCaseTests: XCTestCase {

    func test_deleteEntity_success() async throws {
        let store = InMemoryDatabaseStore()
        let entity = TestEntity(id: "1", value: 99)

        try await store.save(entity, id: "1")

        let useCase = DefaultDeleteEntityUseCase(database: store)
        try await useCase.execute(TestEntity.self, id: "1")

        await XCTAssertThrowsErrorAsync {
            let _: TestEntity =
                try await store.fetch(TestEntity.self, id: "1")
        }
    }
}
