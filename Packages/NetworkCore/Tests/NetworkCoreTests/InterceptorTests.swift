//
//  InterceptorTests.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

actor MockInterceptor: RequestInterceptorProtocol {
    private(set) var adapted = false
    private(set) var handled = false

    func adapt(_ request: NetworkRequest) async throws -> NetworkRequest {
        adapted = true
        return request
    }

    func handle(response: NetworkResponse, request: NetworkRequest) async throws -> NetworkResponse {
        handled = true
        return response
    }
}

final class InterceptorTests: XCTestCase {

    func test_interceptor_isCalled() async throws {
        let interceptor = MockInterceptor()
        let handler = DefaultResponseHandler()

        let mockSession = UploadMockSession()
        mockSession.dataToReturn = Data("OK".utf8)

        let client = URLSessionNetworkClient(
            configuration: .init(baseURL: URL(string:"https://example.com")!),
            session: mockSession,
            interceptors: [interceptor],
            responseHandler: handler,
            requestBuilder: RequestBuilder(),
            logger: nil
        )

        let req = NetworkRequest(
            baseURL: URL(string:"https://example.com")!,
            path:"/test"
        )

        _ = try await client.send(req)

        let adapted = await interceptor.adapted
        let handled = await interceptor.handled

        XCTAssertTrue(adapted)
        XCTAssertTrue(handled)
    }
}
