//
//  UserRepository.swift
//  Domain
//
//  Created by baner on 12/12/25.
//

public protocol UserRepository: Sendable {
    func getUser(id: String) async throws -> User
}
