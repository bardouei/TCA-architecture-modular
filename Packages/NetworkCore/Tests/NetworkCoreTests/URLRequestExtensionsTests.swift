//
//  URLRequestExtensionsTests.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

final class URLRequestExtensionsTests: XCTestCase {

    func test_addHeaders_addsAllHeaders() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let headers = [
            HTTPHeader(name: "X-Test-1", value: "A"),
            HTTPHeader(name: "X-Test-2", value: "B")
        ]

        request.addHeaders(headers)

        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test-1"), "A")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test-2"), "B")
    }

    func test_setJSONBody_setsBodyAndContentType() throws {
        struct TestBody: Codable, Equatable {
            let name: String
            let age: Int
        }

        var request = URLRequest(url: URL(string: "https://example.com")!)
        let body = TestBody(name: "John", age: 30)

        try request.setJSONBody(body)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), HTTPHeader.ContentType.json)

        let data = try XCTUnwrap(request.httpBody)
        let decoded = try JSONDecoder().decode(TestBody.self, from: data)
        XCTAssertEqual(decoded, body)
    }

    func test_setFormURLEncodedBody_setsBodyAndContentType() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let params = [
            "q": "swift network",
            "page": "1"
        ]

        request.setFormURLEncodedBody(params)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), HTTPHeader.ContentType.formUrlEncoded)

        let bodyData = try! XCTUnwrap(request.httpBody)
        let bodyString = String(data: bodyData, encoding: .utf8) ?? ""

        XCTAssertTrue(bodyString.contains("q=swift%20network") || bodyString.contains("q=swift%2520network"))
        XCTAssertTrue(bodyString.contains("page=1"))
    }
}
