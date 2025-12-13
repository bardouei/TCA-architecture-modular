//
//  NetworkClientProtocol.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

// NetworkCore

public protocol NetworkClientProtocol: Actor, Sendable {
    func send(_ request: NetworkRequest) async throws -> NetworkResponse
    func download(_ request: DownloadRequest) async throws -> DownloadResponse
    func upload(_ request: UploadRequest) async throws -> NetworkResponse
    func sendMultiple(
        _ requests: [NetworkRequest],
        maxConcurrent: Int
    ) async throws -> [NetworkResponse]
}

// Default implementations
public extension NetworkClientProtocol {
    func sendMultiple(
        _ requests: [NetworkRequest],
        maxConcurrent: Int = 3
    ) async throws -> [NetworkResponse] {
        try await withThrowingTaskGroup(of: NetworkResponse.self) { group in
            var results: [NetworkResponse] = []
            results.reserveCapacity(requests.count)
            
            // Start initial batch
            for request in requests.prefix(maxConcurrent) {
                group.addTask {
                    try await self.send(request)
                }
            }
            
            var remainingRequests = requests.dropFirst(maxConcurrent)
            
            // Process results and add new tasks
            for try await result in group {
                results.append(result)
                
                if let nextRequest = remainingRequests.popFirst() {
                    group.addTask {
                        try await self.send(nextRequest)
                    }
                }
            }
            
            return results
        }
    }
}
