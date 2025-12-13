//
//  ResponseHandler.swift
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

public actor DefaultResponseHandler: @preconcurrency ResponseHandlerProtocol {
    public init() {}
    
    public func handle(
        data: Data,
        response: URLResponse,
        request: NetworkRequest
    ) async throws -> NetworkResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        let networkResponse = NetworkResponse(
            request: request,
            statusCode: httpResponse.statusCode,
            data: data,
            headers: httpResponse.headersStringDict
        )
        
        try validate(networkResponse)
        return networkResponse
    }
    
    public func validate(_ response: NetworkResponse) throws {
        switch response.statusCode {
        case 200...299:
            return // Success
            
        case 401:
            throw NetworkError.unauthorized
            
        case 403:
            throw NetworkError.forbidden
            
        case 404:
            throw NetworkError.notFound
            
        case 429:
            let retryAfter = response.headers["retry-after"].flatMap(TimeInterval.init)
            throw NetworkError.rateLimited(retryAfter: retryAfter)
            
        case 500...599:
            let message = String(data: response.data, encoding: .utf8)
            throw NetworkError.serverError(
                statusCode: response.statusCode,
                message: message,
                data: response.data
            )
            
        default:
            let message = String(data: response.data, encoding: .utf8)
            throw NetworkError.serverError(
                statusCode: response.statusCode,
                message: message,
                data: response.data
            )
        }
    }
}

