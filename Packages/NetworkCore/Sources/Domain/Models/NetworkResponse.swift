//
//  NetworkResponse.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public struct NetworkResponse: Sendable {
    public let request: NetworkRequest
    public let statusCode: Int
    public let data: Data
    public let headers: [String: String]
    public let metrics: URLSessionTaskMetrics?
    
    public init(
        request: NetworkRequest,
        statusCode: Int,
        data: Data,
        headers: [String: String],
        metrics: URLSessionTaskMetrics? = nil
    ) {
        self.request = request
        self.statusCode = statusCode
        self.data = data
        self.headers = headers
        self.metrics = metrics
    }
    
    public func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(type, from: data)
    }
    
    public var isSuccess: Bool {
        (200...299).contains(statusCode)
    }
}
