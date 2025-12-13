//
//  MultipartFormDataTests.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

final class MultipartFormDataTests: XCTestCase {

    // MARK: - Helpers

    private func makeRequest() -> NetworkRequest {
        NetworkRequest(
            method: .post,
            baseURL: URL(string: "https://example.com")!,
            path: "/upload"
        )
    }

    private func bodyString(from request: URLRequest) -> String {
        String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
    }

    // MARK: - Tests

    func test_contentType_containsBoundary() {
        let mp = MultipartFormData(parts: [])
        XCTAssertTrue(mp.contentType.contains("multipart/form-data; boundary="))
        XCTAssertTrue(mp.boundary.starts(with: "Boundary-"))
    }

    func test_multipart_textPart_isEncodedCorrectly() async throws {
        let mp = MultipartFormData(parts: [
            .text("Hello World", name: "message")
        ])

        let request = makeRequest()
        let builder = RequestBuilder()
        let urlRequest = try await builder.buildMultipart(from: request, multipartData: mp)

        let body = bodyString(from: urlRequest)

        XCTAssertTrue(body.contains("Content-Disposition: form-data; name=\"message\""))
        XCTAssertTrue(body.contains("Hello World"))
    }

    func test_multipart_dataPart_isEncodedCorrectly() async throws {
        let data = "ABC123".data(using: .utf8)!
        let mp = MultipartFormData(parts: [
            .data(data, fileName: "file.txt", mimeType: "text/plain", name: "upload")
        ])

        let request = makeRequest()
        let builder = RequestBuilder()
        let urlRequest = try await builder.buildMultipart(from: request, multipartData: mp)
        let body = bodyString(from: urlRequest)

        XCTAssertTrue(body.contains("Content-Disposition: form-data; name=\"upload\"; filename=\"file.txt\""))
        XCTAssertTrue(body.contains("Content-Type: text/plain"))
        XCTAssertTrue(body.contains("ABC123"))
    }

    func test_multipart_filePart_readsFileAndEncodesCorrectly() async throws {
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("testFile.bin")
        try "DATA!".data(using: .utf8)!.write(to: tempFile)

        let mp = MultipartFormData(parts: [
            .file(tempFile, fileName: "testFile.bin", mimeType: "application/octet-stream", name: "file")
        ])

        let request = makeRequest()
        let builder = RequestBuilder()
        let urlRequest = try await builder.buildMultipart(from: request, multipartData: mp)
        let body = bodyString(from: urlRequest)

        XCTAssertTrue(body.contains("Content-Disposition: form-data; name=\"file\"; filename=\"testFile.bin\""))
        XCTAssertTrue(body.contains("Content-Type: application/octet-stream"))
        XCTAssertTrue(body.contains("DATA!"))
    }

    func test_multipart_includesBoundaryEndMarker() async throws {
        let mp = MultipartFormData(parts: [
            .text("A", name: "a")
        ])

        let builder = RequestBuilder()
        let request = makeRequest()
        let urlRequest = try await builder.buildMultipart(from: request, multipartData: mp)
        let body = bodyString(from: urlRequest)

        XCTAssertTrue(body.contains("--\(mp.boundary)--"))
    }
}
