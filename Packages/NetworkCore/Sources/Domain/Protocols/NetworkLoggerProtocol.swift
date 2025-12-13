//
//  NetworkLoggerProtocol.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public protocol NetworkLoggerProtocol: Sendable {
    func logRequestStarted(_ request: NetworkRequest)
    func logRequestDetails(_ request: URLRequest)
    func logResponseReceived(_ response: NetworkResponse)
    func logRequestCompleted(_ requestId: UUID, with error: Error?)
    func logRequestFailed(_ requestId: UUID, with error: Error)
    func logDownloadStarted(_ request: DownloadRequest)
    func logDownloadCompleted(_ request: DownloadRequest)
    func logDownloadFailed(_ request: DownloadRequest, with error: Error)
    func logUploadStarted(_ request: UploadRequest)
    func logUploadCompleted(_ request: UploadRequest)
    func logUploadFailed(_ request: UploadRequest, with error: Error)
}
