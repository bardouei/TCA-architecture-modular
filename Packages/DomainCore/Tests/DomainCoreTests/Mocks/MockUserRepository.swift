//
//  MockUserRepository.swift
//  Domain
//
//  Created by baner on 12/12/25.
//

@testable import DomainCore

actor MockUserRepository: UserRepository {
    enum Result: Sendable {
        case success(User)
        case failure(DomainError)
    }

    private var result: Result?

    func setResult(_ result: Result) {
        self.result = result
    }

    func getUser(id: String) async throws -> User {
        guard let result else {
            throw DomainError.userNotFound
        }
        switch result {
        case let .success(user):
            return user
        case let .failure(error):
            throw error
        }
    }
}
