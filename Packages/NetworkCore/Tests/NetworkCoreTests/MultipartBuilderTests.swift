//
//  MultipartBuilderTests.swift
//  NetworkCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import NetworkCore

final class MultipartBuilderTests: XCTestCase {

    func test_buildMultipart_createsProperBody() async throws {
        let builder = RequestBuilder()

        let req = NetworkRequest(baseURL: URL(string:"https://a.com")!, path: "/upload")
        let text = MultipartFormData.Part.text("hello", name: "msg")
        let data = MultipartFormData.Part.data(Data("123".utf8), fileName: "f.txt", mimeType: "text/plain", name: "file")

        let multipart = MultipartFormData(parts: [text, data])

        let urlReq = try await builder.buildMultipart(from: req, multipartData: multipart)

        let body = String(data: urlReq.httpBody!, encoding: .utf8) ?? ""

        XCTAssertTrue(body.contains("form-data; name=\"msg\""))
        XCTAssertTrue(body.contains("hello"))
        XCTAssertTrue(body.contains("filename=\"f.txt\""))
        XCTAssertTrue(body.contains("123"))
    }
}
