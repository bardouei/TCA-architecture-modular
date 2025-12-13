//
//  NetworkRequest.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public struct NetworkRequest: Sendable, Equatable, Hashable {

    public let method: HTTPMethod
    public let baseURL: URL?
    public let path: String
    public let headers: [HTTPHeader]
    public let queryParameters: [String: String]?
    public let body: Data?
    public let timeoutInterval: TimeInterval
    public let cachePolicy: URLRequest.CachePolicy
    public let id: UUID

    public init(
        method: HTTPMethod = .get,
        baseURL: URL? = nil,
        path: String,
        headers: [HTTPHeader] = [],
        queryParameters: [String: String]? = nil,
        body: Data? = nil,
        timeoutInterval: TimeInterval = 30,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        id: UUID = UUID()
    ) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
        self.headers = headers
        self.queryParameters = queryParameters
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.id = id
    }

    // MARK: - Equatable
    public static func == (lhs: NetworkRequest, rhs: NetworkRequest) -> Bool {
        return lhs.method == rhs.method &&
               lhs.baseURL == rhs.baseURL &&
               lhs.path == rhs.path &&
               lhs.headers == rhs.headers &&
               lhs.queryParameters == rhs.queryParameters &&
               lhs.body == rhs.body &&
               lhs.timeoutInterval == rhs.timeoutInterval &&
               lhs.cachePolicy == rhs.cachePolicy
    }

    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(method)
        hasher.combine(baseURL)
        hasher.combine(path)
        hasher.combine(headers)
        hasher.combine(queryParameters)

        if let body = body {
            hasher.combine(body)
        }

        hasher.combine(timeoutInterval)
        hasher.combine(cachePolicy.rawValue)
    }
}

// MARK: - JSON Request Helper
extension NetworkRequest {
    public static func jsonRequest(
        method: HTTPMethod = .get,
        baseURL: URL? = nil,
        path: String,
        headers: [HTTPHeader] = [],
        queryParameters: [String: String]? = nil,
        body: Encodable? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        timeoutInterval: TimeInterval = 30
    ) throws -> NetworkRequest {

        var allHeaders = headers
        allHeaders.append(.contentType(HTTPHeader.ContentType.json))
        allHeaders.append(.accept(HTTPHeader.Accept.json))

        let encodedBody = try body.map { try encoder.encode($0) }

        return NetworkRequest(
            method: method,
            baseURL: baseURL,
            path: path,
            headers: allHeaders,
            queryParameters: queryParameters,
            body: encodedBody,
            timeoutInterval: timeoutInterval
        )
    }
}
