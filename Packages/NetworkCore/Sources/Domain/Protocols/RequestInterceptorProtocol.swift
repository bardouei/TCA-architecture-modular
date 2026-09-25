//
//  RequestInterceptorProtocol.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public protocol RequestInterceptorProtocol: Sendable {
    func adapt(_ request: NetworkRequest) async throws -> NetworkRequest
    func handle(response: NetworkResponse, request: NetworkRequest) async throws -> NetworkResponse
    func shouldRetry(response: NetworkResponse, request: NetworkRequest) async throws -> Bool
}

extension RequestInterceptorProtocol {
    public func adapt(_ request: NetworkRequest) async throws -> NetworkRequest {
        request
    }
    
    public func handle(response: NetworkResponse, request: NetworkRequest) async throws -> NetworkResponse {
        response
    }

    public func shouldRetry(response: NetworkResponse, request: NetworkRequest) async throws -> Bool {
        false
    }
}
