//
//  GetUserUseCaseImpl.swift
//  Domain
//
//  Created by baner on 12/12/25.
//

public final class GetUserUseCaseImpl: GetUserUseCase {

    private let repository: UserRepository

    public init(repository: UserRepository) {
        self.repository = repository
    }

    public func execute(userId: String) async throws -> User {
        guard !userId.isEmpty else {
            throw DomainError.invalidInput
        }

        return try await repository.getUser(id: userId)
    }
}
