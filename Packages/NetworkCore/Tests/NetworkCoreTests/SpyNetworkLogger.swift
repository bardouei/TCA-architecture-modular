//
//  SpyNetworkLogger.swift
//  NetworkCore
//
//  Created by baner on 12/12/25.
//

import Foundation
@testable import NetworkCore

final class SpyNetworkLogger: NetworkLoggerProtocol, @unchecked Sendable {

    private(set) var requestStarted: [NetworkRequest] = []
    private(set) var requestDetails: [URLRequest] = []
    private(set) var responses: [NetworkResponse] = []

    private(set) var completed: [(UUID, Error?)] = []
    private(set) var failed: [(UUID, Error)] = []

    private(set) var downloadStarted: [DownloadRequest] = []
    private(set) var downloadCompleted: [DownloadRequest] = []
    private(set) var downloadFailed: [(DownloadRequest, Error)] = []

    private(set) var uploadStarted: [UploadRequest] = []
    private(set) var uploadCompleted: [UploadRequest] = []
    private(set) var uploadFailed: [(UploadRequest, Error)] = []

    func logRequestStarted(_ request: NetworkRequest) {
        requestStarted.append(request)
    }

    func logRequestDetails(_ request: URLRequest) {
        requestDetails.append(request)
    }

    func logResponseReceived(_ response: NetworkResponse) {
        responses.append(response)
    }

    func logRequestCompleted(_ requestId: UUID, with error: Error?) {
        completed.append((requestId, error))
    }

    func logRequestFailed(_ requestId: UUID, with error: Error) {
        failed.append((requestId, error))
    }

    func logDownloadStarted(_ request: DownloadRequest) {
        downloadStarted.append(request)
    }

    func logDownloadCompleted(_ request: DownloadRequest) {
        downloadCompleted.append(request)
    }

    func logDownloadFailed(_ request: DownloadRequest, with error: Error) {
        downloadFailed.append((request, error))
    }

    func logUploadStarted(_ request: UploadRequest) {
        uploadStarted.append(request)
    }

    func logUploadCompleted(_ request: UploadRequest) {
        uploadCompleted.append(request)
    }

    func logUploadFailed(_ request: UploadRequest, with error: Error) {
        uploadFailed.append((request, error))
    }
}
