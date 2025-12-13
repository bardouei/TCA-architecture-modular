//
//  NetworkCache.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

final class NetworkCacheTests: XCTestCase {

    func test_storeAndRetrieve_returnsCachedResponse() async throws {
        let cache = NetworkCache()
        let request = NetworkRequest(
            method: .get,
            baseURL: URL(string: "https://example.com"),
            path: "/users",
            queryParameters: ["q": "test"],
            body: nil
        )

        let data = "cached-response".data(using: .utf8)!
        let response = NetworkResponse(
            request: request,
            statusCode: 200,
            data: data,
            headers: [:]
        )

        await cache.store(response, for: request, policy: .memoryAndDisk)

        let entry = await cache.retrieve(for: request)
        let cached = try XCTUnwrap(entry)

        XCTAssertEqual(cached.data, data)
        XCTAssertEqual(cached.response.data, data)
        XCTAssertEqual(cached.response.statusCode, 200)
        XCTAssertEqual(cached.response.request.path, request.path)
    }

    func test_remove_deletesCachedEntry() async {
        let cache = NetworkCache()
        let request = NetworkRequest(
            method: .get,
            baseURL: URL(string: "https://example.com"),
            path: "/posts"
        )

        let data = Data([1, 2, 3])
        let response = NetworkResponse(
            request: request,
            statusCode: 200,
            data: data,
            headers: [:]
        )

        await cache.store(response, for: request, policy: .memoryOnly)

        let entryBefore = await cache.retrieve(for: request)
        XCTAssertNotNil(entryBefore)

        await cache.remove(for: request)

        let entryAfter = await cache.retrieve(for: request)
        XCTAssertNil(entryAfter)
    }

    func test_clear_removesAllEntries() async {
        let cache = NetworkCache()

        let r1 = NetworkRequest(
            method: .get,
            baseURL: URL(string: "https://example.com"),
            path: "/a"
        )
        let r2 = NetworkRequest(
            method: .get,
            baseURL: URL(string: "https://example.com"),
            path: "/b"
        )

        let data = Data([0])
        let response1 = NetworkResponse(request: r1, statusCode: 200, data: data, headers: [:])
        let response2 = NetworkResponse(request: r2, statusCode: 200, data: data, headers: [:])

        await cache.store(response1, for: r1)
        await cache.store(response2, for: r2)

        let entry1Before = await cache.retrieve(for: r1)
        let entry2Before = await cache.retrieve(for: r2)

        XCTAssertNotNil(entry1Before)
        XCTAssertNotNil(entry2Before)

        await cache.clear()

        let entry1After = await cache.retrieve(for: r1)
        let entry2After = await cache.retrieve(for: r2)

        XCTAssertNil(entry1After)
        XCTAssertNil(entry2After)
    }

    func test_cacheKey_changesWhenBodyChanges() async {
        let cache = NetworkCache()
        let baseURL = URL(string: "https://example.com")!

        let r1 = NetworkRequest(
            method: .post,
            baseURL: baseURL,
            path: "/resource",
            body: "A".data(using: .utf8)
        )

        let r2 = NetworkRequest(
            method: .post,
            baseURL: baseURL,
            path: "/resource",
            body: "B".data(using: .utf8)
        )

        let response1 = NetworkResponse(request: r1, statusCode: 200, data: Data([1]), headers: [:])
        let response2 = NetworkResponse(request: r2, statusCode: 200, data: Data([2]), headers: [:])

        await cache.store(response1, for: r1)
        await cache.store(response2, for: r2)

        let cached1 = await cache.retrieve(for: r1)
        let cached2 = await cache.retrieve(for: r2)

        XCTAssertEqual(cached1?.data, Data([1]))
        XCTAssertEqual(cached2?.data, Data([2]))
    }
}
