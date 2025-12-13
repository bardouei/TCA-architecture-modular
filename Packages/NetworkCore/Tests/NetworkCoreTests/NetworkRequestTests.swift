//
//  NetworkRequestTests.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

final class NetworkRequestTests: XCTestCase {

    func test_jsonRequest_buildsCorrectRequest() throws {
        struct Body: Codable, Equatable { let name: String }

        let baseURL = URL(string: "https://example.com")!
        let body = Body(name: "John")

        let request = try NetworkRequest.jsonRequest(
            method: .post,
            baseURL: baseURL,
            path: "/users",
            headers: [.authorization("Bearer token")],
            queryParameters: ["q": "test"],
            body: body
        )

        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.baseURL, baseURL)
        XCTAssertEqual(request.path, "/users")
        XCTAssertEqual(request.queryParameters?["q"], "test")
        XCTAssertEqual(request.timeoutInterval, 30)

        let headerDict = Dictionary(uniqueKeysWithValues: request.headers.map { ($0.name, $0.value) })

        XCTAssertEqual(headerDict["Content-Type"], "application/json")
        XCTAssertEqual(headerDict["Accept"], "application/json")
        XCTAssertEqual(headerDict["Authorization"], "Bearer token")

        let decoded = try JSONDecoder().decode(Body.self, from: try XCTUnwrap(request.body))
        XCTAssertEqual(decoded, body)
    }
}

final class NetworkResponseTests: XCTestCase {

    func test_isSuccess_whenStatusCodeIn2xxRange() {
        let req = NetworkRequest(path: "/")
        let res1 = NetworkResponse(request: req, statusCode: 200, data: Data(), headers: [:])
        let res2 = NetworkResponse(request: req, statusCode: 204, data: Data(), headers: [:])
        let res3 = NetworkResponse(request: req, statusCode: 299, data: Data(), headers: [:])

        XCTAssertTrue(res1.isSuccess)
        XCTAssertTrue(res2.isSuccess)
        XCTAssertTrue(res3.isSuccess)

        let res4 = NetworkResponse(request: req, statusCode: 199, data: Data(), headers: [:])
        let res5 = NetworkResponse(request: req, statusCode: 300, data: Data(), headers: [:])
        XCTAssertFalse(res4.isSuccess)
        XCTAssertFalse(res5.isSuccess)
    }

    func test_decode_decodesGivenType() throws {
        struct User: Codable, Equatable { let id: Int; let name: String }

        let user = User(id: 1, name: "Test")
        let data = try JSONEncoder().encode(user)
        let req = NetworkRequest(path: "/user")
        let res = NetworkResponse(request: req, statusCode: 200, data: data, headers: [:])

        let decoded: User = try res.decode(User.self)
        XCTAssertEqual(decoded, user)
    }
}

func assertError(_ error: NetworkError, is expected: NetworkError, file: StaticString = #file, line: UInt = #line) {
    switch (error, expected) {
    case (.badRequest, .badRequest),
         (.unauthorized, .unauthorized),
         (.forbidden, .forbidden),
         (.notFound, .notFound),
         (.unknown, .unknown):
        return  // OK
    default:
        XCTFail("Expected \(expected), but got \(error)", file: file, line: line)
    }
}

final class NetworkErrorTests: XCTestCase {

    func test_fromStatusCode_mapsClientAndServerErrors() {
        let data = "err".data(using: .utf8)

        assertError(NetworkError.from(statusCode: 400), is: .badRequest)
        assertError(NetworkError.from(statusCode: 401), is: .unauthorized)
        assertError(NetworkError.from(statusCode: 403), is: .forbidden)
        assertError(NetworkError.from(statusCode: 404), is: .notFound)

        let server = NetworkError.from(statusCode: 500, data: data)
        switch server {
        case .serverError(let statusCode, _, let returnedData):
            XCTAssertEqual(statusCode, 500)
            XCTAssertEqual(returnedData, data)
        default:
            XCTFail("Expected serverError")
        }
        assertError(NetworkError.from(statusCode: 999), is: .unknown)
    }

    func test_categories_andShouldRetry() {
        let timeout = NetworkError.timeout
        XCTAssertTrue(timeout.isConnectionError)
        XCTAssertTrue(timeout.shouldRetry)

        let notFound = NetworkError.notFound
        XCTAssertTrue(notFound.isClientError)
        XCTAssertFalse(notFound.isServerError)
        XCTAssertFalse(notFound.shouldRetry)

        let serviceUnavailable = NetworkError.serviceUnavailable
        XCTAssertTrue(serviceUnavailable.isServerError)
        XCTAssertTrue(serviceUnavailable.shouldRetry)

        let rateLimitedWithRetry = NetworkError.rateLimited(retryAfter: 10)
        XCTAssertTrue(rateLimitedWithRetry.shouldRetry)

        let rateLimitedWithoutRetry = NetworkError.rateLimited(retryAfter: nil)
        XCTAssertFalse(rateLimitedWithoutRetry.shouldRetry)
    }
}
