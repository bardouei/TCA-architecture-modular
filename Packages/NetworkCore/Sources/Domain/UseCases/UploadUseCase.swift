//
//  UploadUseCase.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public protocol UploadUseCaseProtocol: Sendable {
    func uploadFile(_ request: UploadRequest) async throws -> NetworkResponse
    func uploadFile(
        _ request: UploadRequest,
        progressHandler: @escaping @Sendable (UploadProgress) -> Void
    ) async throws -> NetworkResponse
    func uploadMultiple(
        _ requests: [UploadRequest],
        maxConcurrent: Int
    ) async throws -> [NetworkResponse]
    func uploadMultipart(
        _ request: NetworkRequest,
        multipartData: MultipartFormData
    ) async throws -> NetworkResponse
}

public actor UploadUseCase: UploadUseCaseProtocol {
    private let client: URLSessionNetworkClient
    
    public init(client: URLSessionNetworkClient) {
        self.client = client
    }
    
    // Simple upload without progress
    public func uploadFile(_ request: UploadRequest) async throws -> NetworkResponse {
        try await client.upload(request)
    }
    
    // Upload with progress tracking
    public func uploadFile(
        _ request: UploadRequest,
        progressHandler: @escaping @Sendable (UploadProgress) -> Void
    ) async throws -> NetworkResponse {
        try await client.upload(request, progressHandler: progressHandler)
    }
    
    public func uploadMultiple(
        _ requests: [UploadRequest],
        maxConcurrent: Int = 3
    ) async throws -> [NetworkResponse] {
        try await withThrowingTaskGroup(of: NetworkResponse.self) { group in
            var results: [NetworkResponse] = []
            results.reserveCapacity(requests.count)
            
            for request in requests.prefix(maxConcurrent) {
                group.addTask {
                    try await self.uploadFile(request)
                }
            }
            
            var remainingRequests = requests.dropFirst(maxConcurrent)
            
            for try await result in group {
                results.append(result)
                
                if let nextRequest = remainingRequests.popFirst() {
                    group.addTask {
                        try await self.uploadFile(nextRequest)
                    }
                }
            }
            
            return results
        }
    }
    
    public func uploadMultipart(
        _ request: NetworkRequest,
        multipartData: MultipartFormData
    ) async throws -> NetworkResponse {
        try await client.uploadMultipart(request, multipartData: multipartData)
    }
}
