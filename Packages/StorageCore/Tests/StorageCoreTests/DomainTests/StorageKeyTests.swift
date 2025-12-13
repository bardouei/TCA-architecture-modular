//
//  StorageKeyTests.swift
//  StorageCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import StorageCore

final class StorageKeyTests: XCTestCase {

    func test_equality() {
        XCTAssertEqual(StorageKey("a"), StorageKey("a"))
        XCTAssertNotEqual(StorageKey("a"), StorageKey("b"))
    }

    func test_hashable() {
        let set: Set<StorageKey> = [
            .init("x"),
            .init("x"),
            .init("y")
        ]
        XCTAssertEqual(set.count, 2)
    }

    func test_rawValue() {
        let key = StorageKey("profile.id")
        XCTAssertEqual(key.rawValue, "profile.id")
    }
}
