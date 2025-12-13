//
//  RequestBuilderAdditionalTests.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

final class RequestBuilderAdditionalTests: XCTestCase {

    func test_build_setsTimeoutAndCachePolicy() async throws {
        let builder = RequestBuilder()

        let req = NetworkRequest(
            method: .put,
            baseURL: URL(string: "https://example.com")!,
            path: "/update",
            timeoutInterval: 12,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        let urlReq = try await builder.build(from: req)

        XCTAssertEqual(urlReq.httpMethod, "PUT")
        XCTAssertEqual(urlReq.timeoutInterval, 12)
        XCTAssertEqual(urlReq.cachePolicy, .reloadIgnoringLocalCacheData)
    }

    func test_build_withQueryItems() async throws {
        let builder = RequestBuilder()

        let req = NetworkRequest(
            baseURL: URL(string: "https://example.com")!,
            path: "/items",
            queryParameters: ["a": "1", "b": "2"]
        )

        let urlReq = try await builder.build(from: req)

        let url = try XCTUnwrap(urlReq.url)
        let comp = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))

        XCTAssertEqual(comp.queryItems?.count, 2)
        XCTAssertTrue(comp.queryItems!.contains(URLQueryItem(name:"a", value:"1")))
    }
}
