//
//  RequestInterceptor.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public actor BaseRequestInterceptor: RequestInterceptorProtocol {
    public init() {}
    
    public func adapt(_ request: NetworkRequest) async throws -> NetworkRequest {
        // Base implementation does nothing
        return request
    }
    
    public func handle(response: NetworkResponse, request: NetworkRequest) async throws -> NetworkResponse {
        // Validate status code
        guard response.isSuccess else {
            let message = String(data: response.data, encoding: .utf8)
            throw NetworkError.serverError(
                statusCode: response.statusCode,
                message: message,
                data: response.data
            )
        }
        return response
    }
}
