//
//  AnyNetworkClient.swift
//  NetworkCore
//
//  Created by baner on 12/13/25.
//

import Foundation

public struct AnyNetworkClient: Sendable {

    private let _send: @Sendable (NetworkRequest) async throws -> NetworkResponse
    private let _download: @Sendable (DownloadRequest) async throws -> DownloadResponse
    private let _upload: @Sendable (UploadRequest) async throws -> NetworkResponse
    private let _sendMultiple: @Sendable ([NetworkRequest], Int) async throws -> [NetworkResponse]

    public init<C: NetworkClientProtocol>(_ client: C) {
        _send = { request in
            try await client.send(request)
        }
        _download = { request in
            try await client.download(request)
        }
        _upload = { request in
            try await client.upload(request)
        }
        _sendMultiple = { requests, maxConcurrent in
            try await client.sendMultiple(requests, maxConcurrent: maxConcurrent)
        }
    }

    public func send(_ request: NetworkRequest) async throws -> NetworkResponse {
        try await _send(request)
    }

    public func download(_ request: DownloadRequest) async throws -> DownloadResponse {
        try await _download(request)
    }

    public func upload(_ request: UploadRequest) async throws -> NetworkResponse {
        try await _upload(request)
    }

    public func sendMultiple(
        _ requests: [NetworkRequest],
        maxConcurrent: Int = 3
    ) async throws -> [NetworkResponse] {
        try await _sendMultiple(requests, maxConcurrent)
    }
}
