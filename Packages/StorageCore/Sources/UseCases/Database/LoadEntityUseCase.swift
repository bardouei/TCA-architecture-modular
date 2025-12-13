//
//  LoadEntityUseCase.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public protocol LoadEntityUseCase {
    func execute<T: Codable & Sendable>(_ type: T.Type, id: String) async throws -> T
}

public final class DefaultLoadEntityUseCase: LoadEntityUseCase {

    private let database: DatabaseStore

    public init(database: DatabaseStore) {
        self.database = database
    }

    public func execute<T: Codable & Sendable>(_ type: T.Type, id: String) async throws -> T {
        try await database.fetch(type, id: id)
    }
}
