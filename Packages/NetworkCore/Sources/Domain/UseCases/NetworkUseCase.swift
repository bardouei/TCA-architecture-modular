//
//  NetworkUseCase.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public protocol NetworkUseCaseProtocol: Sendable {
    func execute<T: Decodable>(
        _ request: NetworkRequest,
        expecting type: T.Type
    ) async throws -> T
    
    func executeMultiple<T: Decodable>(
        _ requests: [NetworkRequest],
        expecting type: T.Type,
        maxConcurrent: Int
    ) async throws -> [T]
    
    func executeRaw(_ request: NetworkRequest) async throws -> NetworkResponse
}

public final class NetworkUseCase {

    private let client: any NetworkClientProtocol
    private let decoder: JSONDecoder

    public init(
        client: any NetworkClientProtocol,
        decoder: JSONDecoder = .init()
    ) {
        self.client = client
        self.decoder = decoder
    }

    public func execute<T: Decodable>(
        _ request: NetworkRequest,
        expecting _: T.Type
    ) async throws -> T {
        let response = try await client.send(request)
        return try decoder.decode(T.self, from: response.data)
    }

    public func executeMultiple<T: Decodable>(
        _ requests: [NetworkRequest],
        expecting _: T.Type,
        maxConcurrent: Int = 3
    ) async throws -> [T] {
        let responses = try await client.sendMultiple(
            requests,
            maxConcurrent: maxConcurrent
        )
        return try responses.map {
            try decoder.decode(T.self, from: $0.data)
        }
    }
}
