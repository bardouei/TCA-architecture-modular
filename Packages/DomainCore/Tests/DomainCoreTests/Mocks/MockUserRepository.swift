//
//  MockUserRepository.swift
//  Domain
//
//  Created by baner on 12/12/25.
//

@testable import DomainCore

final class MockUserRepository: UserRepository {

    var result: Result<User, Error>?

    func getUser(id: String) async throws -> User {
        guard let result else {
            fatalError("Result not set")
        }
        return try result.get()
    }
}
