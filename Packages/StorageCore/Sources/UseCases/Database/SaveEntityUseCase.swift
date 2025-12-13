//
//  SaveEntityUseCase.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public protocol SaveEntityUseCase {
    func execute<T: Codable & Sendable>(_ object: T, id: String) async throws
}

public final class DefaultSaveEntityUseCase: SaveEntityUseCase {

    private let database: DatabaseStore

    public init(database: DatabaseStore) {
        self.database = database
    }

    public func execute<T: Codable & Sendable>(_ object: T, id: String) async throws {
        try await database.save(object, id: id)
    }
}
