//
//  NetworkError.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public enum NetworkError: LocalizedError, Sendable {
    // MARK: - Connection Errors
    case noInternetConnection
    case connectionLost
    case networkError(Error)
    case timeout
    case dnsLookupFailed
    
    // MARK: - SSL/TLS Errors
    case sslError(Error)
    case certificateExpired
    case certificateRevoked
    case secureConnectionFailed
    
    // MARK: - Request Errors
    case invalidURL
    case invalidRequest
    case invalidRequestBody
    case encodingError(Error)
    
    // MARK: - Response Errors
    case invalidResponse
    case decodingError(Error)
    case emptyResponse
    
    // MARK: - HTTP Status Code Errors
    case badRequest // 400
    case unauthorized // 401
    case forbidden // 403
    case notFound // 404
    case methodNotAllowed // 405
    case requestTimeout // 408
    case conflict // 409
    case gone // 410
    case preconditionFailed // 412
    case payloadTooLarge // 413
    case uriTooLong // 414
    case unsupportedMediaType // 415
    
    case serverError(statusCode: Int, message: String?, data: Data?) // 500+
    case serviceUnavailable // 503
    case gatewayTimeout // 504
    
    case rateLimited(retryAfter: TimeInterval?) // 429
    
    // MARK: - Redirect Errors
    case tooManyRedirects
    case redirectLoopDetected
    
    // MARK: - Other
    case cancelled
    case unknown
    
    // MARK: - Helper Initializer
    public static func from(statusCode: Int, data: Data? = nil) -> NetworkError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 405: return .methodNotAllowed
        case 408: return .requestTimeout
        case 409: return .conflict
        case 410: return .gone
        case 412: return .preconditionFailed
        case 413: return .payloadTooLarge
        case 414: return .uriTooLong
        case 415: return .unsupportedMediaType
        case 429: return .rateLimited(retryAfter: nil)
        case 500...599: return .serverError(statusCode: statusCode, message: nil, data: data)
        default: return .unknown
        }
    }
    
    // MARK: - Computed Properties
    public var localizedDescription: String {
        switch self {
        case .noInternetConnection: return "No internet connection"
        case .connectionLost: return "Connection lost"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .dnsLookupFailed: return "DNS lookup failed"
        case .timeout: return "The request timed out"
        case .sslError(let error): return "SSL error: \(error.localizedDescription)"
        case .certificateExpired: return "Certificate expired"
        case .certificateRevoked: return "Certificate revoked"
        case .secureConnectionFailed: return "Secure connection failed"
        case .invalidURL: return "Invalid URL"
        case .invalidRequest: return "Invalid request"
        case .invalidRequestBody: return "Invalid request body"
        case .encodingError(let error): return "Encoding error: \(error.localizedDescription)"
        case .invalidResponse: return "Invalid response"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .emptyResponse: return "Empty response"
        case .badRequest: return "Bad request"
        case .unauthorized: return "Unauthorized"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not found"
        case .methodNotAllowed: return "Method not allowed"
        case .requestTimeout: return "Request timeout"
        case .conflict: return "Conflict"
        case .gone: return "Resource is gone"
        case .preconditionFailed: return "Precondition failed"
        case .payloadTooLarge: return "Payload too large"
        case .uriTooLong: return "URI too long"
        case .unsupportedMediaType: return "Unsupported media type"
        case .serverError(let statusCode, let message, _):
            return message.map { "Server error \(statusCode): \($0)" } ?? "Server error \(statusCode)"
        case .serviceUnavailable: return "Service unavailable"
        case .gatewayTimeout: return "Gateway timeout"
        case .rateLimited(let retryAfter):
            return retryAfter.map { "Rate limited. Retry after \($0) seconds" } ?? "Rate limited"
        case .tooManyRedirects: return "Too many redirects"
        case .redirectLoopDetected: return "Redirect loop detected"
        case .cancelled: return "Request cancelled"
        case .unknown: return "Unknown network error"
        }
    }

    public var errorDescription: String? {
        localizedDescription
    }
    
    public var statusCode: Int? {
        switch self {
        case .badRequest: return 400
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .methodNotAllowed: return 405
        case .requestTimeout: return 408
        case .conflict: return 409
        case .gone: return 410
        case .preconditionFailed: return 412
        case .payloadTooLarge: return 413
        case .uriTooLong: return 414
        case .unsupportedMediaType: return 415
        case .rateLimited: return 429
        case .serverError(let statusCode, _, _): return statusCode
        case .serviceUnavailable: return 503
        case .gatewayTimeout: return 504
        default: return nil
        }
    }
    
    public var isConnectionError: Bool {
        switch self {
        case .noInternetConnection, .connectionLost, .networkError, .timeout,
             .dnsLookupFailed, .sslError, .certificateExpired, .certificateRevoked,
             .secureConnectionFailed:
            return true
        default:
            return false
        }
    }
    
    public var isClientError: Bool {
        guard let code = statusCode else { return false }
        return (400...499).contains(code)
    }
    
    public var isServerError: Bool {
        guard let code = statusCode else { return false }
        return (500...599).contains(code)
    }
    
    public var shouldRetry: Bool {
        switch self {
        case .timeout, .connectionLost, .serviceUnavailable, .gatewayTimeout:
            return true
        case .rateLimited(let retryAfter):
            return retryAfter != nil
        default:
            return false
        }
    }
}
