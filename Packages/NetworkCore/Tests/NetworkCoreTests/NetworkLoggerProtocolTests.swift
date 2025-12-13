//
//  NetworkLoggerTests.swift
//  NetworkCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import NetworkCore

final class NetworkLoggerProtocolTests: XCTestCase {

    func test_logRequestStarted() {
        let logger = SpyNetworkLogger()
        let req = NetworkRequest(path: "/a")

        logger.logRequestStarted(req)

        XCTAssertEqual(logger.requestStarted.count, 1)
        XCTAssertEqual(logger.requestStarted.first?.path, "/a")
    }

    func test_logRequestDetails() {
        let logger = SpyNetworkLogger()
        let urlReq = URLRequest(url: URL(string: "https://example.com")!)

        logger.logRequestDetails(urlReq)

        XCTAssertEqual(logger.requestDetails.count, 1)
    }

    func test_logResponseReceived() {
        let logger = SpyNetworkLogger()
        let req = NetworkRequest(path: "/a")
        let res = NetworkResponse(request: req, statusCode: 200, data: Data(), headers: [:])

        logger.logResponseReceived(res)

        XCTAssertEqual(logger.responses.count, 1)
        XCTAssertEqual(logger.responses.first?.statusCode, 200)
    }

    func test_logRequestCompleted() {
        let logger = SpyNetworkLogger()
        let id = UUID()

        logger.logRequestCompleted(id, with: nil)

        XCTAssertEqual(logger.completed.count, 1)
        XCTAssertEqual(logger.completed.first?.0, id)
        XCTAssertNil(logger.completed.first?.1)
    }

    func test_logRequestFailed() {
        let logger = SpyNetworkLogger()
        let id = UUID()

        logger.logRequestFailed(id, with: NetworkError.timeout)

        XCTAssertEqual(logger.failed.count, 1)
    }

    func test_downloadLogs() {
        let logger = SpyNetworkLogger()
        let req = DownloadRequest(
            url: URL(string: "https://example.com/file")!,
            destinationURL: URL(fileURLWithPath: "/tmp/file")
        )

        logger.logDownloadStarted(req)
        logger.logDownloadCompleted(req)
        logger.logDownloadFailed(req, with: NetworkError.notFound)

        XCTAssertEqual(logger.downloadStarted.count, 1)
        XCTAssertEqual(logger.downloadCompleted.count, 1)
        XCTAssertEqual(logger.downloadFailed.count, 1)
    }

    func test_uploadLogs() {
        let logger = SpyNetworkLogger()
        let req = UploadRequest(
            request: NetworkRequest(path: "/upload"),
            fileURL: URL(fileURLWithPath: "/tmp/file")
        )

        logger.logUploadStarted(req)
        logger.logUploadCompleted(req)
        logger.logUploadFailed(req, with: NetworkError.unauthorized)

        XCTAssertEqual(logger.uploadStarted.count, 1)
        XCTAssertEqual(logger.uploadCompleted.count, 1)
        XCTAssertEqual(logger.uploadFailed.count, 1)
    }
}
