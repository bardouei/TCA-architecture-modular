//
//  LoggingInterceptor.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation
import os

public actor LoggingInterceptor: RequestInterceptorProtocol {
    private let logger: Logger
    private let logLevel: LogLevel
    
    public enum LogLevel: Sendable {
        case none
        case basic
        case headers
        case body
        case verbose
    }
    
    public init(subsystem: String = "Network", category: String = "Request", logLevel: LogLevel = .basic) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.logLevel = logLevel
    }
    
    public func adapt(_ request: NetworkRequest) async throws -> NetworkRequest {
        guard logLevel != .none else { return request }
        
        logger.log("🚀 Sending request: \(request.method.rawValue) \(request.path)")
        
        if logLevel == .verbose || logLevel == .headers {
            logHeaders(request.headers)
        }
        
        if logLevel == .verbose || logLevel == .body, let body = request.body {
            logBody(body)
        }
        
        return request
    }
    
    public func handle(response: NetworkResponse, request: NetworkRequest) async throws -> NetworkResponse {
        guard logLevel != .none else { return response }
        
        let statusEmoji = response.isSuccess ? "✅" : "❌"
        logger.log("\(statusEmoji) Received response: \(response.statusCode) for \(request.method.rawValue) \(request.path)")
        
        if logLevel == .verbose || logLevel == .headers {
            logger.log("📋 Response headers: \(response.headers)")
        }
        
        if logLevel == .verbose || logLevel == .body {
            logger.log("📦 Response body size: \(response.data.count) bytes")
        }
        
        if let metrics = response.metrics, logLevel == .verbose {
            logMetrics(metrics)
        }
        
        return response
    }
    
    private func logHeaders(_ headers: [HTTPHeader]) {
        headers.forEach { header in
            logger.log("📋 Header: \(header.name): \(header.value)")
        }
    }
    
    private func logBody(_ body: Data) {
        if let json = try? JSONSerialization.jsonObject(with: body),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            logger.log("📦 Request body:\n\(jsonString)")
        } else if let string = String(data: body, encoding: .utf8) {
            logger.log("📦 Request body: \(string)")
        }
    }
    
    private func logMetrics(_ metrics: URLSessionTaskMetrics) {
        metrics.transactionMetrics.forEach { metric in
            logger.log("⏱️ Metrics - Fetch start: \(metric.fetchStartDate?.description ?? "N/A")")
            logger.log("⏱️ Metrics - Response end: \(metric.responseEndDate?.description ?? "N/A")")
        }
    }
}
