//
//  DeleteEntityUseCase.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public protocol DeleteEntityUseCase {
    func execute<T: Codable & Sendable>(_ type: T.Type, id: String) async throws
}

public final class DefaultDeleteEntityUseCase: DeleteEntityUseCase {

    private let database: DatabaseStore

    public init(database: DatabaseStore) {
        self.database = database
    }

    public func execute<T: Sendable>(_ type: T.Type, id: String) async throws {
        try await database.delete(type, id: id)
    }
}
