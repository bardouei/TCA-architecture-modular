//
//  ResponseHandlerValidateTests.swift
//  NetworkCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import NetworkCore

final class ResponseHandlerValidateTests: XCTestCase {

    func test_validate_allows2xx() async throws {
        let handler = DefaultResponseHandler()
        let req = NetworkRequest(path: "/")
        let res = NetworkResponse(request: req, statusCode: 204, data: Data(), headers: [:])

        await XCTAssertNoThrowAsync {
            try await handler.validate(res)
        }
    }

    func test_validate_throwsClientError() async {
        let handler = DefaultResponseHandler()
        let req = NetworkRequest(path:"/")
        let res = NetworkResponse(request: req, statusCode: 404, data: Data(), headers: [:])

        await XCTAssertThrowsErrorAsync {
            try await handler.validate(res)
        } onError: { error in
            guard case NetworkError.notFound = error else {
                return XCTFail("Expected .notFound")
            }
        }
    }

    func test_validate_throwsServerError() async {
        let handler = DefaultResponseHandler()
        let req = NetworkRequest(path:"/")
        let res = NetworkResponse(request: req, statusCode: 500, data: Data("err".utf8), headers: [:])

        await XCTAssertThrowsErrorAsync {
            try await handler.validate(res)
        } onError: { error in
            guard case NetworkError.serverError(let code, _, _) = error else {
                return XCTFail("Expected serverError")
            }
            XCTAssertEqual(code, 500)
        }
    }
}

extension XCTestCase {
    func XCTAssertNoThrowAsync(
        _ expression: @escaping () async throws -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        do {
            try await expression()
        } catch {
            XCTFail("Expected no error, but threw: \(error)", file: file, line: line)
        }
    }
}
