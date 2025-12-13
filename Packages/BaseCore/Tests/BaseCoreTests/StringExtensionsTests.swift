//
//  CoreTests.swift
//  BaseCore
//
//  Created by baner on 12/9/25.
//

import XCTest
@testable import BaseCore

final class StringExtensionsTests: XCTestCase {

    func test_isNotEmpty() {
        XCTAssertTrue("test".isNotEmpty)
        XCTAssertFalse("".isNotEmpty)
    }

    func test_trimmed() {
        XCTAssertEqual("  test ".trimmed(), "test")
    }
}
