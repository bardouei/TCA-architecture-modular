//
//  DefaultResponseHandlerTests.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

final class DefaultResponseHandlerTests: XCTestCase {

    // MARK: - Helpers

    private func response(
        _ status: Int,
        headers: [String: String] = [:]
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: status,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
    }

    private func dummyRequest(path: String = "/") -> NetworkRequest {
        NetworkRequest(path: path)
    }

    // MARK: - Success cases

    func test_successful_200_returnsResponse() async throws {
        let handler = DefaultResponseHandler()
        let req = dummyRequest()
        let data = "ok".data(using: .utf8)!

        let http = response(200, headers: ["X-Test": "1"])
        let result = try await handler.handle(data: data, response: http, request: req)

        XCTAssertEqual(result.statusCode, 200)
        XCTAssertEqual(result.data, data)
        XCTAssertEqual(result.headers["x-test"], "1")
    }

    func test_successResponsesPass_generic() async throws {
        let handler = DefaultResponseHandler()
        let req = dummyRequest()
        let data = Data()

        let res = try await handler.handle(data: data, response: response(201), request: req)
        XCTAssertEqual(res.statusCode, 201)
    }

    // MARK: - Auth & client errors

    func test_unauthorized_throws() async {
        let handler = DefaultResponseHandler()

        await assertThrows(NetworkError.unauthorized) {
            _ = try await handler.handle(
                data: Data(),
                response: self.response(401),
                request: self.dummyRequest()
            )
        }
    }

    func test_forbidden_throws() async {
        let handler = DefaultResponseHandler()

        await assertThrows(NetworkError.forbidden) {
            _ = try await handler.handle(
                data: Data(),
                response: self.response(403),
                request: self.dummyRequest()
            )
        }
    }

    func test_notFound_throws() async {
        let handler = DefaultResponseHandler()

        await assertThrows(NetworkError.notFound) {
            _ = try await handler.handle(
                data: Data(),
                response: self.response(404),
                request: self.dummyRequest()
            )
        }
    }

    // MARK: - Rate Limited

    func test_rateLimited_includesRetryAfter() async {
        let handler = DefaultResponseHandler()
        let http = response(429, headers: ["retry-after": "10"])

        await XCTAssertThrowsErrorAsync {
            _ = try await handler.handle(data: Data(), response: http, request: self.dummyRequest())
        } onError: { error in
            guard case NetworkError.rateLimited(let val) = error else {
                return XCTFail("Expected rateLimited, got \(error)")
            }
            XCTAssertEqual(val, 10)
        }
    }

    // MARK: - Server error

    func test_serverError_throwsWithBody() async {
        let handler = DefaultResponseHandler()
        let req = dummyRequest()
        let body = "Internal error".data(using: .utf8)!
        let http = response(500)

        await XCTAssertThrowsErrorAsync {
            _ = try await handler.handle(data: body, response: http, request: req)
        } onError: { error in
            guard case NetworkError.serverError(let code, let message, let returnedBody) = error else {
                return XCTFail("Expected serverError, got \(error)")
            }
            XCTAssertEqual(code, 500)
            XCTAssertEqual(message, "Internal error")
            XCTAssertEqual(returnedBody, body)
        }
    }

    // MARK: - Invalid Response

    func test_invalidResponse_throwsInvalidResponse() async {
        let handler = DefaultResponseHandler()
        let req = NetworkRequest(path: "/")

        let invalid = URLResponse(
            url: URL(string: "https://example.com")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )

        await assertThrows(NetworkError.invalidResponse) {
            _ = try await handler.handle(
                data: Data(),
                response: invalid,
                request: req
            )
        }
    }
}

// MARK: - Async Throw Helper Extensions

extension XCTestCase {

    func assertThrows<E: Error>(
        _ expectedType: E,
        _ expression: @escaping () async throws -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        do {
            try await expression()
            XCTFail("Expected error but nothing thrown", file: file, line: line)
        } catch {
            XCTFail("Unexpected error type: \(error)", file: file, line: line)
        }
    }

    func XCTAssertThrowsErrorAsync(
        _ expression: @escaping () async throws -> Void,
        onError: (Error) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        do {
            try await expression()
            XCTFail("Expected error but got none", file: file, line: line)
        } catch {
            onError(error)
        }
    }
}
