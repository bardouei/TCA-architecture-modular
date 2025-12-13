//
//  AsyncAssert.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import XCTest

func XCTAssertThrowsErrorAsync(
    _ expression: @escaping () async throws -> Void,
    file: StaticString = #file,
    line: UInt = #line
) async {
    do {
        try await expression()
        XCTFail("Expected error but succeeded", file: file, line: line)
    } catch { }
}
