//
//  NetworkCacheTests.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

final class NetworkCacheAdvancedTests: XCTestCase {

    func test_noCachePolicyDoesNotStore() async {
        let cache = NetworkCache()
        let req = NetworkRequest(baseURL: nil, path: "/item")

        let response = NetworkResponse(request: req, statusCode: 200, data: Data("ok".utf8), headers: [:])
        await cache.store(response, for: req, policy: .noCache)

        let retrieved = await cache.retrieve(for: req)
        XCTAssertNil(retrieved)
    }

    func test_memoryOnlyStores() async {
        let cache = NetworkCache()
        let req = NetworkRequest(baseURL: nil, path: "/item")
        let resp = NetworkResponse(request: req, statusCode: 200, data: Data("X".utf8), headers: [:])

        await cache.store(resp, for: req, policy: .memoryOnly)
        let value = await cache.retrieve(for: req)
        XCTAssertNotNil(value)
    }

    func test_cacheKeyChangesWithQueryParams() async {
        let cache = NetworkCache()

        let r1 = NetworkRequest(path: "/a", queryParameters: ["q": "1"])
        let r2 = NetworkRequest(path: "/a", queryParameters: ["q": "2"])

        let resp1 = NetworkResponse(request: r1, statusCode: 200, data: Data("1".utf8), headers: [:])
        let resp2 = NetworkResponse(request: r2, statusCode: 200, data: Data("2".utf8), headers: [:])

        await cache.store(resp1, for: r1)
        await cache.store(resp2, for: r2)

        let cached1 = await cache.retrieve(for: r1)
        let cached2 = await cache.retrieve(for: r2)

        XCTAssertEqual(cached1?.data, Data("1".utf8))
        XCTAssertEqual(cached2?.data, Data("2".utf8))
    }
    
    func test_cache_overwritesPrevious() async throws {
        let cache = NetworkCache()

        let req = NetworkRequest(path:"/x")

        let r1 = NetworkResponse(request: req, statusCode: 200, data: Data("1".utf8), headers: [:])
        let r2 = NetworkResponse(request: req, statusCode: 200, data: Data("2".utf8), headers: [:])

        await cache.store(r1, for: req)
        await cache.store(r2, for: req)

        let loaded = await cache.retrieve(for: req)
        XCTAssertEqual(String(data: loaded?.data ?? Data(), encoding: .utf8), "2")
    }

    func test_cache_key_changesWithQuery() async {
        let cache = NetworkCache()

        let r1 = NetworkRequest(path:"/item", queryParameters: ["a":"1"])
        let r2 = NetworkRequest(path:"/item", queryParameters: ["a":"2"])

        await cache.store(NetworkResponse(request: r1, statusCode: 200, data: Data("A".utf8), headers: [:]), for: r1)
        await cache.store(NetworkResponse(request: r2, statusCode: 200, data: Data("B".utf8), headers: [:]), for: r2)

        let cacheEntry1 = await cache.retrieve(for: r1)
        let cacheEntry2 = await cache.retrieve(for: r2)

        XCTAssertEqual(String(data: cacheEntry1!.data, encoding: .utf8), "A")
        XCTAssertEqual(String(data: cacheEntry2!.data, encoding: .utf8), "B")
    }
}
