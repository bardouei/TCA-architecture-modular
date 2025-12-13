//
//  URLSessionNetworkClientDownloadTests.swift
//  NetworkCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import NetworkCore

// Mock Session for download testing
final class MockDownloadSession: URLSessionProtocol, @unchecked Sendable {
    var fileURLToReturn: URL = FileManager.default.temporaryDirectory.appendingPathComponent("tmpfile")
    var responseToReturn: URLResponse =
        HTTPURLResponse(url: URL(string: "https://example.com")!,
                        statusCode: 200,
                        httpVersion: "HTTP/1.1",
                        headerFields: nil)!

    var errorToThrow: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        fatalError("Not used")
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        if let e = errorToThrow { throw e }
        return (fileURLToReturn, responseToReturn)
    }

    func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        fatalError("Not used")
    }
}

final class NetworkClientDownloadTests: XCTestCase {

    func test_download_movesFileToDestination() async throws {
        let mock = MockDownloadSession()

        // Create temporary file
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("source_test")
        try "hello".data(using: .utf8)!.write(to: temp)
        mock.fileURLToReturn = temp

        let handler = DefaultResponseHandler()
        let builder = RequestBuilder()

        let client = URLSessionNetworkClient(
            configuration: .init(baseURL: URL(string:"https://example.com")!),
            session: mock,
            interceptors: [],
            responseHandler: handler,
            requestBuilder: builder,
            logger: nil
        )

        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("final_file")

        let req = DownloadRequest(
            url: URL(string:"https://example.com/test")!,
            destinationURL: destination
        )

        let res = try await client.download(req)

        XCTAssertTrue(FileManager.default.fileExists(atPath: destination.path))
        let data = try Data(contentsOf: destination)
        XCTAssertEqual(String(data: data, encoding: .utf8), "hello")

        XCTAssertEqual(res.localURL, destination)
    }

    func test_download_throwsMappedError() async {
        let mock = MockDownloadSession()
        mock.errorToThrow = URLError(.timedOut)

        let client = URLSessionNetworkClient(
            configuration: .init(baseURL: URL(string:"https://example.com")!),
            session: mock,
            interceptors: [],
            responseHandler: DefaultResponseHandler(),
            requestBuilder: RequestBuilder(),
            logger: nil
        )

        let req = DownloadRequest(
            url: URL(string:"https://example.com")!,
            destinationURL: FileManager.default.temporaryDirectory.appendingPathComponent("x")
        )
        
        do {
            _ = try await client.download(req)
            XCTFail("Expected timeout")
        } catch let err as NetworkError {
            switch err {
            case .timeout:
                break
            default:
                XCTFail("Expected .timeout, got \(err)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
