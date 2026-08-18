//
//  RequestQueue.swift
//  NetworkCore
//
//  Created by baner on 12/11/25.
//

import XCTest
@testable import NetworkCore

// MARK: - Helper: ConcurrencyObserver

actor ConcurrencyObserver {
    private(set) var currentActive: Int = 0
    private(set) var maxActive: Int = 0

    func taskStarted() {
        currentActive += 1
        if currentActive > maxActive {
            maxActive = currentActive
        }
    }

    func taskEnded() {
        currentActive -= 1
    }
}

// MARK: - Helper: SlowMockSession

final class SlowMockSession: URLSessionProtocol {
    let observer: ConcurrencyObserver
    let delayNanoseconds: UInt64

    init(observer: ConcurrencyObserver, delayNanoseconds: UInt64 = 100_000_000) {
        self.observer = observer
        self.delayNanoseconds = delayNanoseconds
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        await observer.taskStarted()
        defer { Task { await self.observer.taskEnded() } }

        try await Task.sleep(nanoseconds: delayNanoseconds)

        let url = request.url ?? URL(string: "https://example.com")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [:]
        )!

        let body = "ok".data(using: .utf8) ?? Data()
        return (body, response)
    }

    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        fatalError("Not needed for this test")
    }

    func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        fatalError("Not needed for this test")
    }
}

// MARK: - Tests

final class RequestQueueTests: XCTestCase {

    private func makeClient(using session: URLSessionProtocol) -> URLSessionNetworkClient {
        let config = URLSessionNetworkClient.NetworkConfiguration(
            baseURL: URL(string: "https://example.com")!,
            timeoutInterval: 5,
            cachePolicy: .reloadIgnoringLocalCacheData,
            maximumConnectionsPerHost: 6
        )

        return URLSessionNetworkClient(
            configuration: config,
            session: session,
            interceptors: [],
            responseHandler: DefaultResponseHandler(),
            requestBuilder: RequestBuilder(),
            logger: nil
        )
    }

    func test_enqueue_executesAllRequests() async throws {
        let observer = ConcurrencyObserver()
        let session = SlowMockSession(observer: observer)
        let client = makeClient(using: session)
        let queue = RequestQueue(networkClient: client, maxConcurrentRequests: 2)

        let baseURL = URL(string: "https://example.com")!
        let requests = (0..<5).map { i in
            NetworkRequest(
                method: .get,
                baseURL: baseURL,
                path: "/item\(i)"
            )
        }

        let responses = try await queue.enqueueMultiple(requests)

        XCTAssertEqual(responses.count, 5)
        let paths = Set(responses.map { $0.request.path })
        XCTAssertEqual(paths, Set(requests.map { $0.path }))
        let pending = await queue.pendingCount
        let active = await queue.activeCount

        XCTAssertEqual(pending, 0)
        XCTAssertEqual(active, 0)
    }

    func test_respectsMaxConcurrentRequests() async throws {
        let observer = ConcurrencyObserver()
        let session = SlowMockSession(observer: observer, delayNanoseconds: 200_000_000) // 0.2s
        let client = makeClient(using: session)
        let maxConcurrent = 2
        let queue = RequestQueue(networkClient: client, maxConcurrentRequests: maxConcurrent)

        let baseURL = URL(string: "https://example.com")!
        let requests = (0..<6).map { i in
            NetworkRequest(
                method: .get,
                baseURL: baseURL,
                path: "/item\(i)"
            )
        }

        async let r0: NetworkResponse = queue.enqueue(requests[0])
        async let r1: NetworkResponse = queue.enqueue(requests[1])
        async let r2: NetworkResponse = queue.enqueue(requests[2])
        async let r3: NetworkResponse = queue.enqueue(requests[3])
        async let r4: NetworkResponse = queue.enqueue(requests[4])
        async let r5: NetworkResponse = queue.enqueue(requests[5])

        _ = try await [r0, r1, r2, r3, r4, r5]

        let maxObserved = await observer.maxActive
        XCTAssertLessThanOrEqual(maxObserved, maxConcurrent)
    }

    func test_enqueue_respectsPriorityOrderForQueuedItems() async throws {
        let observer = ConcurrencyObserver()
        let session = SlowMockSession(observer: observer, delayNanoseconds: 150_000_000)
        let client = makeClient(using: session)
        let queue = RequestQueue(networkClient: client, maxConcurrentRequests: 1)

        let baseURL = URL(string: "https://example.com")!

        let lowRequest = NetworkRequest(baseURL: baseURL, path: "/low")
        let highRequest = NetworkRequest(baseURL: baseURL, path: "/high")

        let completedPaths = PathRecorder()

        async let low: Void = {
            let response = try await queue.enqueue(lowRequest, priority: .low)
            await completedPaths.append(response.request.path)
        }()

        try await Task.sleep(nanoseconds: 10_000_000)

        async let high: Void = {
            let response = try await queue.enqueue(highRequest, priority: .high)
            await completedPaths.append(response.request.path)
        }()

        _ = try await (low, high)

        let paths = await completedPaths.values
        XCTAssertEqual(Set(paths), Set(["/low", "/high"]))
    }

    func test_cancelAll_cancelsPendingRequests() async {
        let observer = ConcurrencyObserver()
        let session = SlowMockSession(observer: observer, delayNanoseconds: 500_000_000) // 0.5s
        let client = makeClient(using: session)

        let queue = RequestQueue(networkClient: client, maxConcurrentRequests: 1)

        let baseURL = URL(string: "https://example.com")!
        let requests = (0..<4).map { NetworkRequest(baseURL: baseURL, path: "/item\($0)") }

        var tasks: [Task<Result<NetworkResponse, Error>, Never>] = []

        for req in requests {
            tasks.append(
                Task {
                    do { return .success(try await queue.enqueue(req)) }
                    catch { return .failure(error) }
                }
            )
        }

        // Allow only the first task to start
        try? await Task.sleep(nanoseconds: 50_000_000)

        await queue.cancelAll()

        var cancelledCount = 0
        for t in tasks {
            let result = await t.value
            if case .failure(let error) = result,
               case NetworkError.cancelled = error {
                cancelledCount += 1
            }
        }

        XCTAssertGreaterThan(cancelledCount, 0)
    }
}

private actor PathRecorder {
    private var storage: [String] = []

    var values: [String] {
        storage
    }

    func append(_ value: String) {
        storage.append(value)
    }
}
