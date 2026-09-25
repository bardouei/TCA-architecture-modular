//
//  Email.swift
//  Domain
//
//  Created by baner on 12/12/25.
//

import Foundation

public struct Email: Codable, Equatable, Hashable, Sendable {
    public let value: String

    public init(_ value: String) throws {
        let normalizedValue = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard Email.isValid(normalizedValue) else {
            throw DomainError.invalidEmail
        }
        self.value = normalizedValue
    }

    private static func isValid(_ email: String) -> Bool {
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2,
              !parts[0].isEmpty,
              !parts[1].isEmpty,
              !parts[1].hasPrefix("."),
              !parts[1].hasSuffix(".") else {
            return false
        }
        return parts[1].contains(".")
    }
}
