//
//  NetworkRequestEquatableTests.swift
//  NetworkCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import NetworkCore

final class NetworkRequestEquatableTests: XCTestCase {

    func test_equalRequests_areEqual() {
        let r1 = NetworkRequest(method: .get, path:"/a", queryParameters: ["x":"1"])
        let r2 = NetworkRequest(method: .get, path:"/a", queryParameters: ["x":"1"])

        XCTAssertEqual(r1, r2)
    }

    func test_inequalRequests_areNotEqual() {
        let r1 = NetworkRequest(path:"/a")
        let r2 = NetworkRequest(path:"/b")

        XCTAssertNotEqual(r1, r2)
    }

    func test_hash_changesWithBody() {
        let r1 = NetworkRequest(path:"/a", body: Data("1".utf8))
        let r2 = NetworkRequest(path:"/a", body: Data("2".utf8))

        var h1 = Hasher()
        var h2 = Hasher()

        r1.hash(into: &h1)
        r2.hash(into: &h2)

        XCTAssertNotEqual(h1.finalize(), h2.finalize())
    }

    func test_defaultValues() {
        let r = NetworkRequest(path:"/x")

        XCTAssertEqual(r.method, .get)
        XCTAssertEqual(r.timeoutInterval, 30)
        XCTAssertEqual(r.cachePolicy, .useProtocolCachePolicy)
    }
}
