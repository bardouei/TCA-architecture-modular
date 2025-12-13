//
//  RequestBuilderTests.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//


import XCTest
@testable import NetworkCore

final class RequestBuilderTests: XCTestCase {

    func test_build_createsURLRequestWithAllProperties() async throws {
        let baseURL = URL(string: "https://api.example.com")!
        let request = NetworkRequest(
            method: .post,
            baseURL: baseURL,
            path: "/v1/users",
            headers: [
                .init(name: "X-Custom", value: "123")
            ],
            queryParameters: [
                "q": "search",
                "page": "1"
            ],
            body: "body".data(using: .utf8),
            timeoutInterval: 60,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        let builder = RequestBuilder()
        let urlRequest = try await builder.build(from: request)

        XCTAssertEqual(urlRequest.url?.scheme, "https")
        XCTAssertEqual(urlRequest.url?.host, "api.example.com")
        XCTAssertEqual(urlRequest.url?.path, "/v1/users")

        let components = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)
        let queryDict = Dictionary(uniqueKeysWithValues: (components?.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(queryDict["q"], "search")
        XCTAssertEqual(queryDict["page"], "1")

        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.timeoutInterval, 60)
        XCTAssertEqual(urlRequest.cachePolicy, .reloadIgnoringLocalCacheData)
        XCTAssertEqual(urlRequest.httpBody, "body".data(using: .utf8))
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-Custom"), "123")
    }

    func test_build_withoutBaseURL_throwsInvalidURL() async {
        let request = NetworkRequest(
            method: .get,
            baseURL: nil,
            path: "/test"
        )

        let builder = RequestBuilder()
        do {
            _ = try await builder.build(from: request)
            XCTFail("Expected invalidURL error")
        } catch let error as NetworkError {
            guard case .invalidURL = error else {
                return XCTFail("Expected invalidURL error, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func test_buildMultipart_setsContentTypeAndBody() async throws {
        let baseURL = URL(string: "https://example.com")!
        let request = NetworkRequest(baseURL: baseURL, path: "/upload")

        let multipart = MultipartFormData(parts: [
            .text("value", name: "field"),
            .data("file-content".data(using: .utf8)!, fileName: "file.txt", mimeType: "text/plain", name: "file")
        ])

        let builder = RequestBuilder()
        let urlRequest = try await builder.buildMultipart(from: request, multipartData: multipart)

        XCTAssertEqual(
            urlRequest.value(forHTTPHeaderField: "Content-Type"),
            multipart.contentType
        )

        XCTAssertNotNil(urlRequest.httpBody)
        XCTAssertGreaterThan(urlRequest.httpBody!.count, 0)

        let bodyString = String(data: urlRequest.httpBody!, encoding: .utf8) ?? ""
        XCTAssertTrue(bodyString.contains("value"))
        XCTAssertTrue(bodyString.contains("file.txt"))
        XCTAssertTrue(bodyString.contains(multipart.boundary))
    }
}
