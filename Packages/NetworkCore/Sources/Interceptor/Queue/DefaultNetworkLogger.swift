//
//  DefaultNetworkLogger.swift
//  Networking
//
//  Created by baner on 12/10/25.
//


import Foundation
import os

public struct DefaultNetworkLogger: NetworkLoggerProtocol {
    private let logger = Logger(subsystem: "Networking", category: "HTTP")
    private let redactedHeaders = Set(["authorization"])

    public init() {}

    public func logRequestStarted(_ request: NetworkRequest) {
        logger.debug("➡️ \(request.method.rawValue) \(request.path)")
    }

    public func logRequestDetails(_ request: URLRequest) {
        #if DEBUG
        logger.debug("\(self.curlString(from: request))")
        #endif
    }

    public func logResponseReceived(_ response: NetworkResponse) {
        logger.debug("⬅️ \(response.statusCode) \(response.request.path)")
    }

    public func logRequestCompleted(_ requestId: UUID, with error: Error?) {
        if let error {
            logger.error("❌ \(requestId.uuidString) \(error.localizedDescription)")
        } else {
            logger.debug("✅ \(requestId.uuidString) completed")
        }
    }

    public func logRequestFailed(_ requestId: UUID, with error: Error) {
        logger.error("❌ \(requestId.uuidString) \(error.localizedDescription)")
    }

    public func logDownloadStarted(_ request: DownloadRequest) { logger.debug("⬇️ \(request.url.absoluteString)") }
    public func logDownloadCompleted(_ request: DownloadRequest) { logger.debug("✅ Download completed") }
    public func logDownloadFailed(_ request: DownloadRequest, with error: Error) { logger.error("❌ Download failed: \(error.localizedDescription)") }
    public func logUploadStarted(_ request: UploadRequest) { logger.debug("⬆️ \(request.request.path)") }
    public func logUploadCompleted(_ request: UploadRequest) { logger.debug("✅ Upload completed") }
    public func logUploadFailed(_ request: UploadRequest, with error: Error) { logger.error("❌ Upload failed: \(error.localizedDescription)") }

    private func curlString(from request: URLRequest) -> String {
        var components = ["curl -i"]
        if let method = request.httpMethod { components.append("-X \(method)") }
        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                let k = key.lowercased()
                let v = redactedHeaders.contains(k) ? "<redacted>" : value
                components.append("-H '\(key): \(v)'")
            }
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8), !bodyString.isEmpty {
            components.append("--data '\(bodyString.replacingOccurrences(of: "'", with: "\\'"))'")
        }
        if let url = request.url?.absoluteString { components.append("'\(url)'") }
        return components.joined(separator: " ")
    }
}
