//
//  DownloadUseCase.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public protocol DownloadUseCaseProtocol: Sendable {
    func downloadFile(_ request: DownloadRequest) async throws -> DownloadResponse
    func downloadMultiple(
        _ requests: [DownloadRequest],
        maxConcurrent: Int
    ) async throws -> [DownloadResponse]
}

public actor DownloadUseCase: DownloadUseCaseProtocol {
    private let client: URLSessionNetworkClient
    
    public init(client: URLSessionNetworkClient) {
        self.client = client
    }
    
    public func downloadFile(_ request: DownloadRequest) async throws -> DownloadResponse {
        try await client.download(request)
    }
    
    public func downloadMultiple(
        _ requests: [DownloadRequest],
        maxConcurrent: Int = 3
    ) async throws -> [DownloadResponse] {
        try await withThrowingTaskGroup(of: DownloadResponse.self) { group in
            var results: [DownloadResponse] = []
            results.reserveCapacity(requests.count)
            
            for request in requests.prefix(maxConcurrent) {
                group.addTask {
                    try await self.downloadFile(request)
                }
            }
            
            var remainingRequests = requests.dropFirst(maxConcurrent)
            
            for try await result in group {
                results.append(result)
                
                if let nextRequest = remainingRequests.popFirst() {
                    group.addTask {
                        try await self.downloadFile(nextRequest)
                    }
                }
            }
            
            return results
        }
    }
}
