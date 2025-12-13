//
//  DownloadMockSession.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

final class DownloadMockSession: URLSessionProtocol, @unchecked Sendable {

    var tempFileURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.bin")
    var response: URLResponse =
        HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        fatalError("Not used")
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        try "FILEDATA".data(using: .utf8)!.write(to: tempFileURL)
        return (tempFileURL, response)
    }

    func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        fatalError("Not used")
    }
}

final class DownloadTests: XCTestCase {

    func test_download_movesFileToDestination() async throws {
        let session = DownloadMockSession()

        let client = URLSessionNetworkClient(
            configuration: .init(baseURL: URL(string: "https://example.com")!),
            session: session,
            interceptors: [],
            responseHandler: DefaultResponseHandler(),
            requestBuilder: RequestBuilder(),
            logger: nil
        )

        let dest = FileManager.default.temporaryDirectory.appendingPathComponent("final.bin")

        let req = DownloadRequest(url: URL(string:"https://example.com/file")!, destinationURL: dest)

        let result = try await client.download(req)

        XCTAssertEqual(result.localURL, dest)
        XCTAssertTrue(FileManager.default.fileExists(atPath: dest.path))

        let contents = try String(contentsOf: dest)
        XCTAssertEqual(contents, "FILEDATA")
    }

    func test_download_replacesExistingFile() async throws {
        let session = DownloadMockSession()

        let client = URLSessionNetworkClient(
            configuration: .init(baseURL: URL(string: "https://example.com")!),
            session: session,
            interceptors: [],
            responseHandler: DefaultResponseHandler(),
            requestBuilder: RequestBuilder(),
            logger: nil
        )

        let dest = FileManager.default.temporaryDirectory.appendingPathComponent("replace.bin")

        try "OLD".data(using: .utf8)!.write(to: dest)

        let req = DownloadRequest(url: URL(string:"https://example.com/x")!, destinationURL: dest)

        let result = try await client.download(req)

        let contents = try String(contentsOf: dest)
        XCTAssertEqual(contents, "FILEDATA")
    }
}
