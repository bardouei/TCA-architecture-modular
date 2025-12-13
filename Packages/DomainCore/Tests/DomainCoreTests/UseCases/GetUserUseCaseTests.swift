//
//  GetUserUseCaseTests.swift
//  DomainCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import DomainCore

final class GetUserUseCaseTests: XCTestCase {

    private var repository: MockUserRepository!
    private var useCase: GetUserUseCase!

    override func setUp() {
        super.setUp()
        repository = MockUserRepository()
        useCase = GetUserUseCaseImpl(repository: repository)
    }

    func test_execute_returnsUser_whenRepositorySucceeds() async throws {
        let email = try Email("user@test.com")
        let expectedUser = User(
            id: "1",
            name: "Sadegh",
            email: email
        )

        repository.result = .success(expectedUser)

        let user = try await useCase.execute(userId: "1")

        XCTAssertEqual(user, expectedUser)
    }

    func test_execute_throwsInvalidInput_whenUserIdIsEmpty() async {
        do {
            _ = try await useCase.execute(userId: "")
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as? DomainError, .invalidInput)
        }
    }

    func test_execute_propagatesRepositoryError() async {
        repository.result = .failure(DomainError.userNotFound)

        do {
            _ = try await useCase.execute(userId: "404")
            XCTFail("Expected error not thrown")
        } catch {
            XCTAssertEqual(error as? DomainError, .userNotFound)
        }
    }
}
