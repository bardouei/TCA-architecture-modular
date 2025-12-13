//
//  StorageErrorTests.swift
//  StorageCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import StorageCore

final class StorageErrorTests: XCTestCase {

    func test_simpleCasesEquatable() {
        XCTAssertEqual(StorageError.notFound, .notFound)
        XCTAssertEqual(StorageError.encoding, .encoding)
        XCTAssertNotEqual(StorageError.decoding, .encoding)
    }

    func test_underlyingEquality() {
        XCTAssertEqual(
            StorageError.underlying("A"),
            StorageError.underlying("A")
        )
        XCTAssertNotEqual(
            StorageError.underlying("A"),
            StorageError.underlying("B")
        )
    }
}
