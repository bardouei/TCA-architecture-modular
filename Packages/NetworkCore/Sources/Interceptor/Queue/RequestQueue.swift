//
//  RequestQueue.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public actor RequestQueue {
    public enum Priority: Int, Comparable, Sendable {
        case low = 0
        case medium = 1
        case high = 2
        case urgent = 3
        
        public static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    public struct QueuedRequest: Sendable {
        public let id: UUID
        public let request: NetworkRequest
        public let priority: Priority
        public let createdAt: Date
        
        public init(request: NetworkRequest, priority: Priority = .medium) {
            self.id = UUID()
            self.request = request
            self.priority = priority
            self.createdAt = Date()
        }
    }
    
    private var queue: [QueuedRequest] = []
    private var maxConcurrentRequests: Int
    private var activeRequests: Set<UUID> = []
    private var continuations: [UUID: CheckedContinuation<NetworkResponse, Error>] = [:]
    private var activeTasks: [UUID: Task<NetworkResponse, Error>] = [:]
    
    private let networkClient: URLSessionNetworkClient
    
    public init(
        networkClient: URLSessionNetworkClient,
        maxConcurrentRequests: Int = 3
    ) {
        self.networkClient = networkClient
        self.maxConcurrentRequests = maxConcurrentRequests
    }
    
    public func enqueue(_ request: NetworkRequest, priority: Priority = .medium) async throws -> NetworkResponse {
        let queuedRequest = QueuedRequest(request: request, priority: priority)
        queue.append(queuedRequest)
        queue.sort {
            if $0.priority != $1.priority { return $0.priority > $1.priority }
            return $0.createdAt < $1.createdAt
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            continuations[queuedRequest.id] = continuation
            processNextIfNeeded()
        }
    }
    
    public func enqueueMultiple(
        _ requests: [NetworkRequest],
        priority: Priority = .medium
    ) async throws -> [NetworkResponse] {
        try await withThrowingTaskGroup(of: NetworkResponse.self) { group in
            for request in requests {
                group.addTask {
                    try await self.enqueue(request, priority: priority)
                }
            }
            
            var results: [NetworkResponse] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
    
    public func cancelRequest(id: UUID) {
        if let index = queue.firstIndex(where: { $0.id == id }) {
            queue.remove(at: index)
            if let continuation = continuations.removeValue(forKey: id) {
                continuation.resume(throwing: NetworkError.cancelled)
            }
        }
        if let task = activeTasks.removeValue(forKey: id) {
            task.cancel()
        }
    }
    
    public func cancelAll() {
        for (id, continuation) in continuations {
            continuation.resume(throwing: NetworkError.cancelled)
        }
        queue.removeAll()
        continuations.removeAll()
        activeRequests.removeAll()
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
    
    private func processNextIfNeeded() {
        guard activeRequests.count < maxConcurrentRequests,
              !queue.isEmpty else {
            return
        }

        let nextRequest = queue.removeFirst()
        activeRequests.insert(nextRequest.id)

        let task = Task { () -> NetworkResponse in
            do {
                let response = try await networkClient.send(nextRequest.request)
                requestCompleted(nextRequest.id, with: .success(response))
                return response
            } catch {
                requestCompleted(nextRequest.id, with: .failure(error))
                throw error
            }
        }

        activeTasks[nextRequest.id] = task
    }
    
    private func requestCompleted(
        _ requestId: UUID,
        with result: Result<NetworkResponse, Error>
    ) {
        activeRequests.remove(requestId)
        activeTasks[requestId] = nil

        if let continuation = continuations.removeValue(forKey: requestId) {
            switch result {
            case .success(let response):
                continuation.resume(returning: response)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }

        processNextIfNeeded()
    }
    
    public var pendingCount: Int {
        queue.count
    }
    
    public var activeCount: Int {
        activeRequests.count
    }
    
    public var totalCount: Int {
        queue.count + activeRequests.count
    }
}
