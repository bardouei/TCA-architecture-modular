//
//  RequestInterceptorProtocol.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

final class RequestInterceptorProtocolTests: XCTestCase {

    struct DummyInterceptor: RequestInterceptorProtocol {}

    func test_defaultAdapt_returnsSameRequest() async throws {
        let interceptor = DummyInterceptor()
        let request = NetworkRequest(path: "/")
        let adapted = try await interceptor.adapt(request)
        XCTAssertEqual(adapted.path, request.path)
        XCTAssertEqual(adapted.id, request.id)
    }

    func test_defaultHandle_returnsSameResponse() async throws {
        let interceptor = DummyInterceptor()
        let request = NetworkRequest(path: "/")
        let response = NetworkResponse(request: request, statusCode: 200, data: Data(), headers: [:])

        let handled = try await interceptor.handle(response: response, request: request)
        XCTAssertEqual(handled.statusCode, response.statusCode)
        XCTAssertEqual(handled.data, response.data)
    }
}
