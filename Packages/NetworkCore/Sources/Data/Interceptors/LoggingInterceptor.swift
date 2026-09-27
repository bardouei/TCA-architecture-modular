import Foundation
import os

public actor LoggingInterceptor: RequestInterceptorProtocol {
    public enum LogLevel: Sendable {
        case none
        case basic
        case headers
        case body
        case verbose
    }

    private let logger: Logger
    private let logLevel: LogLevel

    public init(
        subsystem: String = "Network",
        category: String = "Request",
        logLevel: LogLevel = .basic
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.logLevel = logLevel
    }

    public func adapt(_ request: NetworkRequest) async throws -> NetworkRequest {
        guard logLevel != .none else { return request }
        logger.info("Sending \(request.method.rawValue, privacy: .public) \(request.path, privacy: .private(mask: .hash))")
        if logLevel == .verbose || logLevel == .headers {
            logger.debug("Headers: \(String(describing: NetworkLogSanitizer.headers(request.headers)), privacy: .private)")
        }
        if (logLevel == .verbose || logLevel == .body), let body = request.body {
            logger.debug("Body: \(NetworkLogSanitizer.bodyDescription(body), privacy: .public)")
        }
        return request
    }

    public func handle(response: NetworkResponse, request: NetworkRequest) async throws -> NetworkResponse {
        guard logLevel != .none else { return response }
        logger.info("Received status \(response.statusCode, privacy: .public)")
        if logLevel == .verbose || logLevel == .headers {
            logger.debug("Headers: \(String(describing: NetworkLogSanitizer.headers(response.headers)), privacy: .private)")
        }
        if logLevel == .verbose || logLevel == .body {
            logger.debug("Body: \(NetworkLogSanitizer.bodyDescription(response.data), privacy: .public)")
        }
        return response
    }

    public func shouldRetry(response: NetworkResponse, request: NetworkRequest) async throws -> Bool {
        false
    }
}
