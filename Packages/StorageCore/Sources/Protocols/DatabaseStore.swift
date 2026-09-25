//
//  DatabaseStore.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public protocol DatabaseStore: Sendable {
    func save<T: Codable & Sendable>(_ object: T, id: String) async throws
    func fetch<T: Codable & Sendable>(_ type: T.Type, id: String) async throws -> T
    func delete<T: Sendable>(_ type: T.Type, id: String) async throws
}
