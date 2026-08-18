//
//  URLSessionNetworkClient.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public actor URLSessionNetworkClient {
    public let session: any URLSessionProtocol
    public let configuration: NetworkConfiguration
    public let interceptors: [RequestInterceptorProtocol]
    public let responseHandler: ResponseHandlerProtocol
    public let requestBuilder: RequestBuilderProtocol
    public let logger: NetworkLoggerProtocol?
    
    public struct NetworkConfiguration: Sendable {
        public let baseURL: URL
        public let timeoutInterval: TimeInterval
        public let cachePolicy: URLRequest.CachePolicy
        public let maximumConnectionsPerHost: Int
        public let maxRetries: Int
        
        public init(
            baseURL: URL,
            timeoutInterval: TimeInterval = 30,
            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
            maximumConnectionsPerHost: Int = 6,
            maxRetries: Int = 3
        ) {
            self.baseURL = baseURL
            self.timeoutInterval = timeoutInterval
            self.cachePolicy = cachePolicy
            self.maximumConnectionsPerHost = maximumConnectionsPerHost
            self.maxRetries = maxRetries
        }
    }
    
    public init(
        configuration: NetworkConfiguration,
        session: URLSessionProtocol? = nil,
        interceptors: [RequestInterceptorProtocol] = [],
        responseHandler: ResponseHandlerProtocol = DefaultResponseHandler(),
        requestBuilder: RequestBuilderProtocol? = nil,
        logger: NetworkLoggerProtocol? = nil
    ) {
        self.configuration = configuration
        self.session = session ?? URLSession.shared
        self.interceptors = interceptors
        self.responseHandler = responseHandler
        self.requestBuilder = requestBuilder ?? RequestBuilder(configuration: configuration)
        self.logger = logger
    }
    
    // MARK: - Single Request
    
    public func send(_ request: NetworkRequest) async throws -> NetworkResponse {
        let requestId = request.id
        
        logger?.logRequestStarted(request)
        
        do {
            // Apply interceptors
            var adaptedRequest = request
            for interceptor in interceptors {
                adaptedRequest = try await interceptor.adapt(adaptedRequest)
            }
            
            // Build URLRequest
            let urlRequest = try await requestBuilder.build(from: adaptedRequest)
            
            logger?.logRequestDetails(urlRequest)
            
            // Perform request
            let (data, response) = try await session.data(for: urlRequest)
            
            // Handle response
            let networkResponse = try await responseHandler.handle(
                data: data,
                response: response,
                request: adaptedRequest
            )
            
            logger?.logResponseReceived(networkResponse)
            
            // Apply response interceptors using loop
            var finalResponse = networkResponse
            for interceptor in interceptors {
                finalResponse = try await interceptor.handle(
                    response: finalResponse,
                    request: adaptedRequest
                )
            }
            
            logger?.logRequestCompleted(requestId, with: nil)
            return finalResponse
            
        } catch {
            logger?.logRequestFailed(requestId, with: error)
            throw mapError(error)
        }
    }
    
    // MARK: - Multiple Concurrent Requests
    
    public func sendMultiple(
        _ requests: [NetworkRequest],
        maxConcurrent: Int = 3
    ) async throws -> [NetworkResponse] {
        try await withThrowingTaskGroup(of: (Int, NetworkResponse).self) { group in
            var results = Array<NetworkResponse?>(repeating: nil, count: requests.count)
            let initial = min(maxConcurrent, requests.count)
            for i in 0..<initial {
                group.addTask { (i, try await self.send(requests[i])) }
            }
            var nextIndex = initial
            for try await (i, res) in group {
                results[i] = res
                if nextIndex < requests.count {
                    let j = nextIndex
                    group.addTask { (j, try await self.send(requests[j])) }
                    nextIndex += 1
                }
            }
            return results.compactMap { $0 }
        }
    }
    
    // MARK: - Download
    
    public func download(_ request: DownloadRequest) async throws -> DownloadResponse {
        logger?.logDownloadStarted(request)
        
        do {
            var urlRequest = URLRequest(url: request.url)
            urlRequest.timeoutInterval = configuration.timeoutInterval
            request.headers.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.name) }
            
            let (sourceURL, response) = try await session.download(for: urlRequest)
            return try await handleDownloadResult(
                sourceURL: sourceURL,
                response: response,
                request: request
            )
            
        } catch {
            logger?.logDownloadFailed(request, with: error)
            throw mapError(error)
        }
    }
    
    private func handleDownloadResult(
        sourceURL: URL,
        response: URLResponse,
        request: DownloadRequest
    ) async throws -> DownloadResponse {
        // Ensure destination directory exists
        try FileManager.default.createDirectory(
            at: request.destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        // Remove existing file if it exists
        if FileManager.default.fileExists(atPath: request.destinationURL.path) {
            try FileManager.default.removeItem(at: request.destinationURL)
        }
        
        // Move file to destination
        try FileManager.default.moveItem(at: sourceURL, to: request.destinationURL)
        
        logger?.logDownloadCompleted(request)
        
        return DownloadResponse(
            request: request,
            localURL: request.destinationURL,
            response: response,
            progress: 1.0
        )
    }
    
    // MARK: - Upload
    
    public func upload(_ request: UploadRequest) async throws -> NetworkResponse {
        logger?.logUploadStarted(request)
        
        do {
            var urlRequest = try await requestBuilder.build(from: request.request)
            urlRequest.timeoutInterval = configuration.timeoutInterval
            
            let fileData = try Data(contentsOf: request.fileURL)
            let (data, response) = try await session.upload(for: urlRequest, from: fileData)
            
            let networkResponse = try await responseHandler.handle(
                data: data,
                response: response,
                request: request.request
            )
            
            logger?.logUploadCompleted(request)
            return networkResponse
            
        } catch {
            logger?.logUploadFailed(request, with: error)
            throw mapError(error)
        }
    }
    
    public func upload(
        _ request: UploadRequest,
        progressHandler: @escaping @Sendable (UploadProgress) -> Void
    ) async throws -> NetworkResponse {
        logger?.logUploadStarted(request)
        
        do {
            var urlRequest = try await requestBuilder.build(from: request.request)
            urlRequest.timeoutInterval = configuration.timeoutInterval
            
            let fileData = try Data(contentsOf: request.fileURL)
            
            // Simulate progress (in real implementation, use delegate)
            let fileSize = fileData.count
            let chunkSize = max(1, fileSize / 10)
            
            // Start upload
            let (data, response) = try await session.upload(for: urlRequest, from: fileData)
            
            // Report progress
            for i in 1...10 {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                let progress = UploadProgress(
                    request: request,
                    bytesSent: Int64(chunkSize * i),
                    totalBytesSent: Int64(min(chunkSize * i, fileSize)),
                    totalBytesExpectedToSend: Int64(fileSize)
                )
                progressHandler(progress)
            }
            
            let networkResponse = try await responseHandler.handle(
                data: data,
                response: response,
                request: request.request
            )
            
            logger?.logUploadCompleted(request)
            return networkResponse
            
        } catch {
            logger?.logUploadFailed(request, with: error)
            throw mapError(error)
        }
    }
    
    // MARK: - Multipart Upload
    
    public func uploadMultipart(
        _ request: NetworkRequest,
        multipartData: MultipartFormData
    ) async throws -> NetworkResponse {
        let urlRequest = try await requestBuilder.buildMultipart(from: request, multipartData: multipartData)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        return try await responseHandler.handle(
            data: data,
            response: response,
            request: request
        )
    }
    
    // MARK: - Error Mapping
    
    private func mapError(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError { return networkError }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet: return .noInternetConnection
            case .networkConnectionLost:  return .connectionLost
            case .cannotFindHost, .cannotConnectToHost: return .dnsLookupFailed
            case .timedOut: return .timeout
            case .cancelled: return .cancelled
            case .secureConnectionFailed, .serverCertificateUntrusted,
                 .serverCertificateHasBadDate, .serverCertificateHasUnknownRoot:
                return .sslError(urlError)
            default:
                return .networkError(urlError)
            }
        }
        if error is DecodingError { return .decodingError(error) }
        if error is EncodingError { return .encodingError(error) }
        return .unknown
    }
}

// NetworkCore

public extension URLSessionNetworkClient.NetworkConfiguration {
    static let live = Self(
        baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
        timeoutInterval: 30,
        cachePolicy: .useProtocolCachePolicy,
        maximumConnectionsPerHost: 6,
        maxRetries: 3
    )
}

extension URLSessionNetworkClient: NetworkClientProtocol {}
