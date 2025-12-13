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
}

extension RequestInterceptorProtocol {
    public func adapt(_ request: NetworkRequest) async throws -> NetworkRequest {
        request
    }
    
    public func handle(response: NetworkResponse, request: NetworkRequest) async throws -> NetworkResponse {
        response
    }
}
