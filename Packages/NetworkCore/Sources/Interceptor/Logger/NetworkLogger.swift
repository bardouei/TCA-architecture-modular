//
//  NetworkLogger.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation
import os

public actor NetworkLogger: NetworkLoggerProtocol {
    private let logger: Logger
    private let includeMetrics: Bool
    
    public init(
        subsystem: String = "com.network.module",
        category: String = "Network",
        includeMetrics: Bool = false
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.includeMetrics = includeMetrics
    }
    
    // MARK: - Nonisolated Methods
    
    public nonisolated func logRequestStarted(_ request: NetworkRequest) {
        Task {
            await _logRequestStarted(request)
        }
    }
    
    public nonisolated func logRequestDetails(_ request: URLRequest) {
        Task {
            await _logRequestDetails(request)
        }
    }
    
    public nonisolated func logResponseReceived(_ response: NetworkResponse) {
        Task {
            await _logResponseReceived(response)
        }
    }
    
    public nonisolated func logRequestCompleted(_ requestId: UUID, with error: Error?) {
        Task {
            await _logRequestCompleted(requestId, with: error)
        }
    }
    
    public nonisolated func logRequestFailed(_ requestId: UUID, with error: Error) {
        Task {
            await _logRequestFailed(requestId, with: error)
        }
    }
    
    public nonisolated func logDownloadStarted(_ request: DownloadRequest) {
        Task {
            await _logDownloadStarted(request)
        }
    }
    
    public nonisolated func logDownloadCompleted(_ request: DownloadRequest) {
        Task {
            await _logDownloadCompleted(request)
        }
    }
    
    public nonisolated func logDownloadFailed(_ request: DownloadRequest, with error: Error) {
        Task {
            await _logDownloadFailed(request, with: error)
        }
    }
    
    public nonisolated func logUploadStarted(_ request: UploadRequest) {
        Task {
            await _logUploadStarted(request)
        }
    }
    
    public nonisolated func logUploadCompleted(_ request: UploadRequest) {
        Task {
            await _logUploadCompleted(request)
        }
    }
    
    public nonisolated func logUploadFailed(_ request: UploadRequest, with error: Error) {
        Task {
            await _logUploadFailed(request, with: error)
        }
    }
    
    // MARK: - Private Actor-Isolated Methods
    
    private func _logRequestStarted(_ request: NetworkRequest) {
        logger.info("🚀 Starting request: \(request.method.rawValue) \(request.path)")
    }
    
    private func _logRequestDetails(_ request: URLRequest) {
        logger.debug("📋 Request URL: \(request.url?.absoluteString ?? "N/A")")
        logger.debug("📋 Request Method: \(request.httpMethod ?? "N/A")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logger.debug("📋 Request Headers: \(headers)")
        }
        
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            logger.debug("📦 Request Body: \(bodyString.prefix(1000))")
        }
    }
    
    private func _logResponseReceived(_ response: NetworkResponse) {
        let statusEmoji = response.isSuccess ? "✅" : "❌"
        logger.info("\(statusEmoji) Response received: \(response.statusCode)")
        
        logger.debug("📋 Response Headers: \(response.headers)")
        logger.debug("📦 Response Data Size: \(response.data.count) bytes")
        
        if let responseString = String(data: response.data, encoding: .utf8) {
            logger.debug("📦 Response Body: \(responseString.prefix(1000))")
        }
        
        if includeMetrics, let metrics = response.metrics {
            logMetrics(metrics)
        }
    }
    
    private func _logRequestCompleted(_ requestId: UUID, with error: Error?) {
        if let error = error {
            logger.error("❌ Request \(requestId) failed: \(error.localizedDescription)")
        } else {
            logger.info("✅ Request \(requestId) completed successfully")
        }
    }
    
    private func _logRequestFailed(_ requestId: UUID, with error: Error) {
        logger.error("💥 Request \(requestId) failed with error: \(error)")
    }
    
    private func _logDownloadStarted(_ request: DownloadRequest) {
        logger.info("⬇️ Starting download: \(request.url.absoluteString)")
        logger.debug("⬇️ Destination: \(request.destinationURL.path)")
    }
    
    private func _logDownloadCompleted(_ request: DownloadRequest) {
        logger.info("✅ Download completed: \(request.url.lastPathComponent)")
    }
    
    private func _logDownloadFailed(_ request: DownloadRequest, with error: Error) {
        logger.error("💥 Download failed for \(request.url.absoluteString): \(error)")
    }
    
    private func _logUploadStarted(_ request: UploadRequest) {
        logger.info("⬆️ Starting upload: \(request.fileURL.lastPathComponent)")
        logger.debug("⬆️ To: \(request.request.path)")
    }
    
    private func _logUploadCompleted(_ request: UploadRequest) {
        logger.info("✅ Upload completed: \(request.fileURL.lastPathComponent)")
    }
    
    private func _logUploadFailed(_ request: UploadRequest, with error: Error) {
        logger.error("💥 Upload failed for \(request.fileURL.lastPathComponent): \(error)")
    }
    
    private func logMetrics(_ metrics: URLSessionTaskMetrics) {
        metrics.transactionMetrics.forEach { metric in
            logger.debug("⏱️ Network Metrics:")
            logger.debug("⏱️   Fetch Start: \(metric.fetchStartDate?.description ?? "N/A")")
            logger.debug("⏱️   Domain Lookup Start: \(metric.domainLookupStartDate?.description ?? "N/A")")
            logger.debug("⏱️   Domain Lookup End: \(metric.domainLookupEndDate?.description ?? "N/A")")
            logger.debug("⏱️   Connect Start: \(metric.connectStartDate?.description ?? "N/A")")
            logger.debug("⏱️   Secure Connection Start: \(metric.secureConnectionStartDate?.description ?? "N/A")")
            logger.debug("⏱️   Secure Connection End: \(metric.secureConnectionEndDate?.description ?? "N/A")")
            logger.debug("⏱️   Connect End: \(metric.connectEndDate?.description ?? "N/A")")
            logger.debug("⏱️   Request Start: \(metric.requestStartDate?.description ?? "N/A")")
            logger.debug("⏱️   Request End: \(metric.requestEndDate?.description ?? "N/A")")
            logger.debug("⏱️   Response Start: \(metric.responseStartDate?.description ?? "N/A")")
            logger.debug("⏱️   Response End: \(metric.responseEndDate?.description ?? "N/A")")
        }
    }
}
