//
//  EmailTests.swift
//  DomainCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import DomainCore

final class EmailTests: XCTestCase {

    func test_validEmail_createsEmailObject() throws {
        let email = try Email("test@example.com")
        XCTAssertEqual(email.value, "test@example.com")
    }

    func test_invalidEmail_throwsError() {
        XCTAssertThrowsError(try Email("invalid-email")) { error in
            XCTAssertEqual(error as? DomainError, .invalidEmail)
        }
    }

    func test_emailIsTrimmedAndNormalized() throws {
        let email = try Email("  TEST@Example.COM  ")
        XCTAssertEqual(email.value, "test@example.com")
    }

    func test_invalidEmailShapesThrow() {
        for value in ["@example.com", "test@", "test@@example.com", "test@.com", "test@example."] {
            XCTAssertThrowsError(try Email(value), "Expected \(value) to be invalid")
        }
    }
}
