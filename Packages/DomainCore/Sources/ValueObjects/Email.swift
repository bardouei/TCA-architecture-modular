//
//  Email.swift
//  Domain
//
//  Created by baner on 12/12/25.
//

import Foundation

public struct Email: Equatable {
    public let value: String

    public init(_ value: String) throws {
        guard Email.isValid(value) else {
            throw DomainError.invalidEmail
        }
        self.value = value
    }

    private static func isValid(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
}
