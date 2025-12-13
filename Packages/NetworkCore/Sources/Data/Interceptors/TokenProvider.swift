//
//  TokenProvider.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public protocol TokenProviderProtocol: Actor {
    var currentToken: String? { get }
    func isTokenExpired(_ token: String) -> Bool
    func refreshToken() async throws -> String
    func updateToken(_ token: String) async
}

public actor InMemoryTokenProvider: TokenProviderProtocol {
    private var token: String?
    private var expirationDate: Date?
    
    public var currentToken: String? {
        token
    }
    
    public init(initialToken: String? = nil, expirationDate: Date? = nil) {
        self.token = initialToken
        self.expirationDate = expirationDate
    }
    
    public func isTokenExpired(_ token: String) -> Bool {
        guard let expirationDate = expirationDate else { return true }
        return Date() > expirationDate
    }
    
    public func refreshToken() async throws -> String {
        // Implement your token refresh logic here
        // This is just a placeholder implementation
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let newToken = "refreshed_token_\(UUID().uuidString)"
        expirationDate = Date().addingTimeInterval(3600) // Expires in 1 hour
        
        return newToken
    }
    
    public func updateToken(_ token: String) {
        self.token = token
        self.expirationDate = Date().addingTimeInterval(3600) // Expires in 1 hour
    }
}
