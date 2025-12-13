//
//  SaveEntityUseCaseTests.swift
//  StorageCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import StorageCore

final class SaveEntityUseCaseTests: XCTestCase {

    func test_saveEntity_success() async throws {
        let store = InMemoryDatabaseStore()
        let useCase = DefaultSaveEntityUseCase(database: store)

        let entity = TestEntity(id: "1", value: 10)

        try await useCase.execute(entity, id: entity.id)

        let fetched: TestEntity =
            try await store.fetch(TestEntity.self, id: "1")

        XCTAssertEqual(fetched, entity)
    }
}
