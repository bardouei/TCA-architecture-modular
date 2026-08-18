//
//  UploadMockSession.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

// MARK: - Mock Types (Swift 6 compatible)

final class UploadMockSession: URLSessionProtocol, @unchecked Sendable {
    var uploadedData: Data?
    var dataToReturn: Data = Data("OK".utf8)
    var response: URLResponse = HTTPURLResponse(
        url: URL(string: "https://example.com")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
    )!

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return (dataToReturn, response)
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        fatalError("Not used")
    }

    func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        self.uploadedData = data
        return (dataToReturn, response)
    }
}

final class UploadMockResponseHandler: ResponseHandlerProtocol, @unchecked Sendable {
    func validate(_ response: NetworkCore.NetworkResponse) throws {}
    
    var responseToReturn: NetworkResponse?

    func handle(data: Data, response: URLResponse, request: NetworkRequest) async throws -> NetworkResponse {
        return responseToReturn ?? NetworkResponse(
            request: request,
            statusCode: 200,
            data: data,
            headers: [:]
        )
    }
}

// MARK: - Tests

final class UploadTests: XCTestCase {

    func makeClient(
        session: URLSessionProtocol,
        handler: UploadMockResponseHandler
    ) -> URLSessionNetworkClient {
        let config = URLSessionNetworkClient.NetworkConfiguration(
            baseURL: URL(string: "https://example.com")!
        )

        return URLSessionNetworkClient(
            configuration: config,
            session: session,
            interceptors: [],
            responseHandler: handler,
            requestBuilder: RequestBuilder(),
            logger: nil
        )
    }

    func test_upload_simple() async throws {
        let session = UploadMockSession()
        let handler = UploadMockResponseHandler()
        let client = makeClient(session: session, handler: handler)

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("file.txt")
        try "HELLO".data(using: .utf8)!.write(to: fileURL)

        handler.responseToReturn = NetworkResponse(
            request: NetworkRequest(path: "/upload"),
            statusCode: 200,
            data: Data("OK".utf8),
            headers: [:]
        )

        let req = UploadRequest(
            request: NetworkRequest(
                method: .post,
                baseURL: URL(string: "https://example.com")!,
                path: "/upload"
            ),
            fileURL: fileURL
        )

        let response = try await client.upload(req)

        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(session.uploadedData, Data("HELLO".utf8))
    }

    func test_upload_withProgress() async throws {
        let session = UploadMockSession()
        let handler = UploadMockResponseHandler()
        let client = makeClient(session: session, handler: handler)

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("file2.txt")
        try Data(repeating: 1, count: 2000).write(to: fileURL)

        handler.responseToReturn = NetworkResponse(
            request: NetworkRequest(path: "/up"),
            statusCode: 200,
            data: Data("DONE".utf8),
            headers: [:]
        )

        let collectedProgress = ProgressRecorder()

        let req = UploadRequest(
            request: NetworkRequest(
                method: .post,
                baseURL: URL(string: "https://example.com")!,
                path: "/up"
            ),
            fileURL: fileURL
        )

        _ = try await client.upload(req) { progress in
            collectedProgress.append(
                Double(progress.bytesSent) / Double(progress.totalBytesExpectedToSend)
            )
        }

        let values = collectedProgress.values
        XCTAssertEqual(values.count, 10)
        XCTAssertEqual(values.last, 1.0)
    }
}

private final class ProgressRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [Double] = []

    var values: [Double] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    func append(_ value: Double) {
        lock.lock()
        defer { lock.unlock() }
        storage.append(value)
    }
}
