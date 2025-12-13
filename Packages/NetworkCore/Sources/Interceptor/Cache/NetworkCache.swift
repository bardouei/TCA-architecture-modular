//
//  NetworkCache.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public actor NetworkCache {
    public enum CachePolicy: Sendable {
        case noCache
        case memoryOnly
        case memoryAndDisk
    }
    
    public struct CacheEntry: Sendable {
        public let data: Data
        public let response: NetworkResponse
        public let timestamp: Date
        
        public init(data: Data, response: NetworkResponse) {
            self.data = data
            self.response = response
            self.timestamp = Date()
        }
    }
    
    private let memoryCache = NSCache<NSString, NSData>()
    private let defaultExpiration: TimeInterval?
    
    public init(
        memoryCapacity: Int = 10 * 1024 * 1024, // 10MB
        defaultExpiration: TimeInterval? = 300 // 5 minutes
    ) {
        memoryCache.totalCostLimit = memoryCapacity
        self.defaultExpiration = defaultExpiration
    }
    
    public func store(
        _ response: NetworkResponse,
        for request: NetworkRequest,
        policy: CachePolicy = .memoryAndDisk
    ) async {
        let cacheKey = await cacheKey(for: request)
        
        switch policy {
        case .memoryOnly, .memoryAndDisk:
            memoryCache.setObject(
                response.data as NSData,
                forKey: cacheKey as NSString,
                cost: response.data.count
            )
        case .noCache:
            break
        }
    }
    
    public func retrieve(for request: NetworkRequest) async -> CacheEntry? {
        let cacheKey = await cacheKey(for: request)
        
        guard let cachedData = memoryCache.object(forKey: cacheKey as NSString) as Data? else {
            return nil
        }
        
        let response = NetworkResponse(
            request: request,
            statusCode: 200,
            data: cachedData,
            headers: [:]
        )
        
        return CacheEntry(data: cachedData, response: response)
    }
    
    public func remove(for request: NetworkRequest) async {
        let cacheKey = await cacheKey(for: request)
        memoryCache.removeObject(forKey: cacheKey as NSString)
    }
    
    public func clear() {
        memoryCache.removeAllObjects()
    }
    
    // MARK: - Private Methods
    
    private func cacheKey(for request: NetworkRequest) async -> String {
        var components: [String] = [
            request.method.rawValue,
            request.path
        ]
        
        if let queryParams = request.queryParameters {
            let sortedParams = queryParams.sorted { $0.key < $1.key }
            let paramString = sortedParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            components.append(paramString)
        }
        
        if let body = request.body {
            let bodyHash = "\(body.hashValue)"
            components.append(bodyHash)
        }
        
        return components.joined(separator: "|")
    }
}
