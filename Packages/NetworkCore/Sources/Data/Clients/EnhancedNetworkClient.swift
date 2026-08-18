//
//  EnhancedNetworkClient.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

private extension HTTPURLResponse {
    var headersStringDict: [String: String] {
        var result: [String: String] = [:]
        for (key, value) in allHeaderFields {
            let k = String(describing: key).lowercased()
            result[k] = String(describing: value)
        }
        return result
    }
}

public actor EnhancedNetworkClient {
    private let session: URLSession
    private let configuration: NetworkConfiguration
    
    public struct NetworkConfiguration: Sendable {
        public let baseURL: URL
        public let timeoutInterval: TimeInterval
        
        public init(baseURL: URL, timeoutInterval: TimeInterval = 30) {
            self.baseURL = baseURL
            self.timeoutInterval = timeoutInterval
        }
    }
    
    public init(configuration: NetworkConfiguration) {
        self.configuration = configuration
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        self.session = URLSession(configuration: sessionConfig)
    }
    
    public func send(_ request: NetworkRequest) async throws -> NetworkResponse {
        guard let url = buildURL(for: request) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeoutInterval
        urlRequest.cachePolicy = request.cachePolicy
        
        request.headers.forEach { header in
            urlRequest.addValue(header.value, forHTTPHeaderField: header.name)
        }
        
        if let body = request.body {
            urlRequest.httpBody = body
        }
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.from(statusCode: httpResponse.statusCode, data: data)
        }
        
        return NetworkResponse(
            request: request,
            statusCode: httpResponse.statusCode,
            data: data,
            headers: httpResponse.headersStringDict
        )
    }
    
    public func download(_ request: DownloadRequest) async throws -> DownloadResponse {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.timeoutInterval = configuration.timeoutInterval
        
        request.headers.forEach { header in
            urlRequest.addValue(header.value, forHTTPHeaderField: header.name)
        }
        
        let (localURL, response) = try await session.download(for: urlRequest)
        
        try FileManager.default.createDirectory(
            at: request.destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        if FileManager.default.fileExists(atPath: request.destinationURL.path) {
            try FileManager.default.removeItem(at: request.destinationURL)
        }
        
        try FileManager.default.moveItem(at: localURL, to: request.destinationURL)
        
        return DownloadResponse(
            request: request,
            localURL: request.destinationURL,
            response: response,
            progress: 1.0
        )
    }
    
    private func buildURL(for request: NetworkRequest) -> URL? {
        let baseURL = request.baseURL ?? configuration.baseURL
        guard let url = URL(string: request.path, relativeTo: baseURL)?.absoluteURL else {
            return nil
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if let queryParams = request.queryParameters {
            components?.queryItems = queryParams
                .sorted { $0.key < $1.key }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        return components?.url
    }
}
