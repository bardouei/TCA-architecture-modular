//
//  LoadEntityUseCaseTests.swift
//  StorageCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import StorageCore

final class LoadEntityUseCaseTests: XCTestCase {

    func test_loadEntity_success() async throws {
        let store = InMemoryDatabaseStore()
        let entity = TestEntity(id: "1", value: 42)

        try await store.save(entity, id: "1")

        let useCase = DefaultLoadEntityUseCase(database: store)
        let result: TestEntity =
            try await useCase.execute(TestEntity.self, id: "1")

        XCTAssertEqual(result, entity)
    }

    func test_loadEntity_notFound() async {
        let store = InMemoryDatabaseStore()
        let useCase = DefaultLoadEntityUseCase(database: store)

        await XCTAssertThrowsErrorAsync {
            let _: TestEntity =
                try await useCase.execute(TestEntity.self, id: "404")
        }
    }
}
