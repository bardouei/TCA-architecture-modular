//
//  User.swift
//  Domain
//
//  Created by baner on 12/12/25.
//

import Foundation

public struct User: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let email: Email

    public init(
        id: String,
        name: String,
        email: Email
    ) {
        self.id = id
        self.name = name
        self.email = email
    }
}
