//
//  MockUploadSession.swift
//  NetworkCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import NetworkCore

final class MockUploadSession: URLSessionProtocol, @unchecked Sendable {
    var dataToReturn: Data = Data()
    var responseToReturn: URLResponse =
        HTTPURLResponse(url: URL(string:"https://example.com")!,
                        statusCode: 200,
                        httpVersion: "HTTP/1.1",
                        headerFields: nil)!

    var errorToThrow: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        fatalError("Not used")
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        fatalError("Not used")
    }

    func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        if let e = errorToThrow { throw e }
        return (dataToReturn, responseToReturn)
    }
}

final class NetworkClientUploadTests: XCTestCase {

    func test_upload_success() async throws {
        let mock = MockUploadSession()
        mock.dataToReturn = Data("UP".utf8)

        let handler = MockResponseHandler()
        handler.responseToReturn = NetworkResponse(
            request: NetworkRequest(path: "/"),
            statusCode: 200,
            data: Data("UP".utf8),
            headers: [:]
        )

        let client = URLSessionNetworkClient(
            configuration: .init(baseURL: URL(string:"https://example.com")!),
            session: mock,
            interceptors: [],
            responseHandler: handler,
            requestBuilder: RequestBuilder(),
            logger: nil
        )

        let tmpFile = FileManager.default.temporaryDirectory.appendingPathComponent("u_test")
        try Data("12345".utf8).write(to: tmpFile)
        
        let uploadReq = UploadRequest(
            request: NetworkRequest(
                baseURL: URL(string: "https://example.com")!,
                path: "/upload"
            ),
            fileURL: tmpFile
        )

        let res = try await client.upload(uploadReq)

        XCTAssertEqual(String(data: res.data, encoding: .utf8), "UP")
    }
    
    func test_upload_progressHandler_calls10Steps() async throws {
        let mock = MockUploadSession()
        mock.dataToReturn = Data("OK".utf8)

        let handler = MockResponseHandler()
        handler.responseToReturn = NetworkResponse(
            request: NetworkRequest(path:"/"),
            statusCode: 200,
            data: Data("OK".utf8),
            headers: [:]
        )

        let client = URLSessionNetworkClient(
            configuration: .init(baseURL: URL(string:"https://example.com")!),
            session: mock,
            interceptors: [],
            responseHandler: handler,
            requestBuilder: RequestBuilder(),
            logger: nil
        )

        let file = FileManager.default.temporaryDirectory.appendingPathComponent("progress")
        try Data(repeating: 1, count: 1000).write(to: file)

        actor Counter {
            private(set) var value = 0
            func inc() { value += 1 }
        }

        let counter = Counter()

        let uploadReq = UploadRequest(
            request: NetworkRequest(
                baseURL: URL(string:"https://example.com")!,
                path:"/p"
            ),
            fileURL: file
        )

        _ = try await client.upload(uploadReq) { progress in
            Task { await counter.inc() }
        }

        let final = await counter.value
        XCTAssertEqual(final, 10)
    }
}
