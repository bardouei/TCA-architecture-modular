import Foundation
import os

enum NetworkLogSanitizer {
    private static let sensitiveHeaders = [
        "authorization", "cookie", "set-cookie", "x-api-key", "proxy-authorization"
    ]

    static func headers(_ headers: [String: String]) -> [String: String] {
        headers.reduce(into: [:]) { result, entry in
            result[entry.key] = sensitiveHeaders.contains(entry.key.lowercased()) ? "<redacted>" : entry.value
        }
    }

    static func headers(_ headers: [HTTPHeader]) -> [String: String] {
        self.headers(Dictionary(uniqueKeysWithValues: headers.map { ($0.name, $0.value) }))
    }

    static func url(_ url: URL?) -> String {
        guard let url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return "N/A"
        }
        if components.queryItems?.isEmpty == false {
            components.query = "<redacted>"
        }
        return components.string ?? "\(url.scheme ?? "https")://\(url.host ?? "<unknown>")"
    }

    static func bodyDescription(_ data: Data) -> String {
        data.isEmpty ? "<empty>" : "<\(data.count) bytes; payload logging disabled>"
    }
}

public struct NetworkLogger: NetworkLoggerProtocol, Sendable {
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

    public func logRequestStarted(_ request: NetworkRequest) {
        logger.info("Starting request: \(request.method.rawValue, privacy: .public) \(request.path, privacy: .private(mask: .hash))")
    }

    public func logRequestDetails(_ request: URLRequest) {
        logger.debug("Request URL: \(NetworkLogSanitizer.url(request.url), privacy: .private(mask: .hash))")
        logger.debug("Request method: \(request.httpMethod ?? "N/A", privacy: .public)")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logger.debug("Request headers: \(String(describing: NetworkLogSanitizer.headers(headers)), privacy: .private)")
        }
        if let body = request.httpBody {
            logger.debug("Request body: \(NetworkLogSanitizer.bodyDescription(body), privacy: .public)")
        }
    }

    public func logResponseReceived(_ response: NetworkResponse) {
        logger.info("Response status: \(response.statusCode, privacy: .public)")
        logger.debug("Response headers: \(String(describing: NetworkLogSanitizer.headers(response.headers)), privacy: .private)")
        logger.debug("Response body: \(NetworkLogSanitizer.bodyDescription(response.data), privacy: .public)")
        if includeMetrics, let metrics = response.metrics {
            logMetrics(metrics)
        }
    }

    public func logRequestCompleted(_ requestId: UUID, with error: Error?) {
        if let error {
            logger.error("Request \(requestId.uuidString, privacy: .private(mask: .hash)) failed: \(error.localizedDescription, privacy: .private)")
        } else {
            logger.info("Request \(requestId.uuidString, privacy: .private(mask: .hash)) completed")
        }
    }

    public func logRequestFailed(_ requestId: UUID, with error: Error) {
        logger.error("Request \(requestId.uuidString, privacy: .private(mask: .hash)) failed: \(error.localizedDescription, privacy: .private)")
    }

    public func logDownloadStarted(_ request: DownloadRequest) {
        logger.info("Download started: \(NetworkLogSanitizer.url(request.url), privacy: .private(mask: .hash))")
    }

    public func logDownloadCompleted(_ request: DownloadRequest) {
        logger.info("Download completed: \(request.url.lastPathComponent, privacy: .private(mask: .hash))")
    }

    public func logDownloadFailed(_ request: DownloadRequest, with error: Error) {
        logger.error("Download failed: \(error.localizedDescription, privacy: .private)")
    }

    public func logUploadStarted(_ request: UploadRequest) {
        logger.info("Upload started: \(request.fileURL.lastPathComponent, privacy: .private(mask: .hash))")
    }

    public func logUploadCompleted(_ request: UploadRequest) {
        logger.info("Upload completed: \(request.fileURL.lastPathComponent, privacy: .private(mask: .hash))")
    }

    public func logUploadFailed(_ request: UploadRequest, with error: Error) {
        logger.error("Upload failed: \(error.localizedDescription, privacy: .private)")
    }

    private func logMetrics(_ metrics: URLSessionTaskMetrics) {
        for metric in metrics.transactionMetrics {
            logger.debug("Network protocol: \(metric.networkProtocolName ?? "unknown", privacy: .public)")
            if let start = metric.fetchStartDate, let end = metric.responseEndDate {
                logger.debug("Network duration: \(end.timeIntervalSince(start), privacy: .public) seconds")
            }
        }
    }
}
