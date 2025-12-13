//
//  AuthenticationInterceptor.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public actor AuthenticationInterceptor: RequestInterceptorProtocol {
    private let tokenProvider: TokenProviderProtocol
    private var isRefreshing = false
    private var refreshTask: Task<String, Error>?
    
    public init(tokenProvider: TokenProviderProtocol) {
        self.tokenProvider = tokenProvider
    }
    
    public func adapt(_ request: NetworkRequest) async throws -> NetworkRequest {
        let token = try await getValidToken()
        
        var headers = request.headers
        headers.append(.authorization(bearer: token))
        
        return NetworkRequest(
            method: request.method,
            baseURL: request.baseURL,
            path: request.path,
            headers: headers,
            queryParameters: request.queryParameters,
            body: request.body,
            timeoutInterval: request.timeoutInterval,
            cachePolicy: request.cachePolicy,
            id: request.id
        )
    }
    
    public func handle(response: NetworkResponse, request: NetworkRequest) async throws -> NetworkResponse {
        if response.statusCode == 401 {
            // Token expired, refresh and retry
            _ = try await refreshToken()
            throw NetworkError.unauthorized
        }
        
        return response
    }
    
    private func getValidToken() async throws -> String {
        if let token = await tokenProvider.currentToken,
           !(await tokenProvider.isTokenExpired(token)) {
            return token
        }
        
        return try await refreshToken()
    }
    
    private func refreshToken() async throws -> String {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }
        
        let task = Task<String, Error> {
            defer { self.refreshTask = nil }
            let newToken = try await tokenProvider.refreshToken()
            await tokenProvider.updateToken(newToken)
            return newToken
        }
        
        self.refreshTask = task
        return try await task.value
    }
}
