//
//  GetUserUseCase.swift
//  Domain
//
//  Created by baner on 12/9/25.
//

public protocol GetUserUseCase: Sendable {
    func execute(userId: String) async throws -> User
}
