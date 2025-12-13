//
//  URLSessionNetworkClientSendTests.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

final class MockSession: URLSessionProtocol, @unchecked Sendable {
    var dataToReturn: Data = Data()
    var responseToReturn: URLResponse = HTTPURLResponse(
        url: URL(string: "https://example.com")!,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]
    )!
    var errorToThrow: Error?

    private(set) var lastRequest: URLRequest?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        if let e = errorToThrow { throw e }
        return (dataToReturn, responseToReturn)
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        fatalError("Not needed for these tests")
    }

    func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        fatalError("Not needed for these tests")
    }
}

// MARK: - Mock RequestBuilder

/// Mock برای RequestBuilderProtocol
final class MockRequestBuilder: RequestBuilderProtocol {
    var urlRequest = URLRequest(url: URL(string: "https://example.com/api")!)
    private(set) var lastNetworkRequest: NetworkRequest?

    func build(from request: NetworkRequest) async throws -> URLRequest {
        lastNetworkRequest = request
        return urlRequest
    }

    func buildMultipart(from request: NetworkRequest, multipartData: MultipartFormData) async throws -> URLRequest {
        fatalError("Not needed for these tests")
    }
}

// MARK: - Mock ResponseHandler

/// Mock برای ResponseHandlerProtocol
final class MockResponseHandler: ResponseHandlerProtocol {
    var responseToReturn: NetworkResponse?
    var errorToThrow: Error?

    private(set) var lastInputData: Data?
    private(set) var lastInputResponse: URLResponse?
    private(set) var lastInputRequest: NetworkRequest?

    func handle(data: Data, response: URLResponse, request: NetworkRequest) async throws -> NetworkResponse {
        lastInputData = data
        lastInputResponse = response
        lastInputRequest = request

        if let e = errorToThrow { throw e }
        guard let responseToReturn else {
            fatalError("responseToReturn must be set before calling handle")
        }
        return responseToReturn
    }

    func validate(_ response: NetworkResponse) throws {
        // برای این تست‌ها نیازی به validate نداریم
    }
}

// MARK: - Tests

final class URLSessionNetworkClientSendTests: XCTestCase {

    private func makeClient(
        session: URLSessionProtocol,
        interceptors: [RequestInterceptorProtocol] = [],
        builder: RequestBuilderProtocol,
        handler: ResponseHandlerProtocol
    ) -> URLSessionNetworkClient {

        let config = URLSessionNetworkClient.NetworkConfiguration(
            baseURL: URL(string: "https://example.com")!,
            timeoutInterval: 10,
            cachePolicy: .reloadIgnoringLocalCacheData,
            maximumConnectionsPerHost: 5
        )

        return URLSessionNetworkClient(
            configuration: config,
            session: session,
            interceptors: interceptors,
            responseHandler: handler,
            requestBuilder: builder,
            logger: nil
        )
    }

    func test_send_callsInterceptorAdapt() async throws {
        let session = MockSession()
        let builder = MockRequestBuilder()
        let handler = MockResponseHandler()
        let interceptor = MockInterceptor()

        let expectedResponse = NetworkResponse(
            request: NetworkRequest(path: "/"),
            statusCode: 200,
            data: Data(),
            headers: [:]
        )
        handler.responseToReturn = expectedResponse

        let client = makeClient(
            session: session,
            interceptors: [interceptor],
            builder: builder,
            handler: handler
        )

        let req = NetworkRequest(
            baseURL: URL(string: "https://example.com")!,
            path: "/test"
        )

        _ = try await client.send(req)

        let adapted = await interceptor.adapted
        XCTAssertTrue(adapted)
    }

    func test_send_callsRequestBuilder() async throws {
        let session = MockSession()
        let builder = MockRequestBuilder()
        let handler = MockResponseHandler()

        handler.responseToReturn = NetworkResponse(
            request: NetworkRequest(path: "/"),
            statusCode: 200,
            data: Data(),
            headers: [:]
        )

        let client = makeClient(
            session: session,
            interceptors: [],
            builder: builder,
            handler: handler
        )

        let req = NetworkRequest(
            baseURL: URL(string: "https://example.com")!,
            path: "/builder"
        )

        _ = try await client.send(req)

        let builtReq = builder.lastNetworkRequest
        XCTAssertEqual(builtReq?.path, "/builder")
    }

    func test_send_callsSessionData() async throws {
        let session = MockSession()
        let builder = MockRequestBuilder()
        let handler = MockResponseHandler()

        handler.responseToReturn = NetworkResponse(
            request: NetworkRequest(path: "/"),
            statusCode: 200,
            data: Data(),
            headers: [:]
        )

        let client = makeClient(
            session: session,
            interceptors: [],
            builder: builder,
            handler: handler
        )

        let req = NetworkRequest(
            baseURL: URL(string: "https://example.com")!,
            path: "/session"
        )

        _ = try await client.send(req)

        XCTAssertNotNil(session.lastRequest)
    }

    func test_send_callsResponseHandler() async throws {
        let session = MockSession()
        let builder = MockRequestBuilder()
        let handler = MockResponseHandler()

        let inputData = "hello".data(using: .utf8)!
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        session.dataToReturn = inputData
        session.responseToReturn = httpResponse

        handler.responseToReturn = NetworkResponse(
            request: NetworkRequest(path: "/"),
            statusCode: 200,
            data: inputData,
            headers: [:]
        )

        let client = makeClient(
            session: session,
            interceptors: [],
            builder: builder,
            handler: handler
        )

        let req = NetworkRequest(
            baseURL: URL(string: "https://example.com")!,
            path: "/handler"
        )

        _ = try await client.send(req)

        let received = handler.lastInputData
        XCTAssertEqual(received, inputData)
    }

    func test_send_callsInterceptorHandle() async throws {
        let session = MockSession()
        let builder = MockRequestBuilder()
        let handler = MockResponseHandler()
        let interceptor = MockInterceptor()

        let resp = NetworkResponse(
            request: NetworkRequest(path: "/"),
            statusCode: 200,
            data: Data(),
            headers: [:]
        )
        handler.responseToReturn = resp

        let client = makeClient(
            session: session,
            interceptors: [interceptor],
            builder: builder,
            handler: handler
        )

        let req = NetworkRequest(
            baseURL: URL(string: "https://example.com")!,
            path: "/abc"
        )

        _ = try await client.send(req)

        let handled = await interceptor.handled
        XCTAssertTrue(handled)
    }

    func test_send_mapsURLErrorToNetworkError() async {
        let session = MockSession()
        let builder = MockRequestBuilder()
        let handler = MockResponseHandler()

        session.errorToThrow = URLError(.timedOut)

        let client = makeClient(
            session: session,
            interceptors: [],
            builder: builder,
            handler: handler
        )

        let req = NetworkRequest(
            baseURL: URL(string: "https://example.com")!,
            path: "/timeout"
        )

        do {
            _ = try await client.send(req)
            XCTFail("Expected timeout error")
        } catch let err as NetworkError {
            switch err {
            case .timeout:
                break // OK
            default:
                XCTFail("Expected .timeout, got \(err)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
