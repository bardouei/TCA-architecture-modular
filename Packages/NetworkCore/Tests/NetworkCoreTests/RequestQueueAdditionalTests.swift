//
//  RequestQueueAdditionalTests.swift
//  NetworkCore
//
//  Created by baner on 12/12/25.
//

import XCTest
@testable import NetworkCore

private func makeClient(
    using session: URLSessionProtocol,
    handler: ResponseHandlerProtocol = DefaultResponseHandler(),
    builder: RequestBuilderProtocol = RequestBuilder(),
    interceptors: [RequestInterceptorProtocol] = []
) -> URLSessionNetworkClient {

    let config = URLSessionNetworkClient.NetworkConfiguration(
        baseURL: URL(string: "https://example.com")!,
        timeoutInterval: 5,
        cachePolicy: .reloadIgnoringLocalCacheData,
        maximumConnectionsPerHost: 5
    )

    return URLSessionNetworkClient(
        configuration: config,
        session: session,
        interceptors: interceptors,
        responseHandler: handler,
        requestBuilder: builder,
        logger: nil
    )
}

func test_cancelSpecificRequest() async throws {
    let obs = ConcurrencyObserver()
    let session = SlowMockSession(observer: obs)
    let client = makeClient(using: session)
    let queue = RequestQueue(networkClient: client, maxConcurrentRequests: 1)

    let req1 = NetworkRequest(baseURL: URL(string:"https://a.com")!, path:"/1")
    let req2 = NetworkRequest(baseURL: URL(string:"https://a.com")!, path:"/2")

    let task1 = Task {
        try await queue.enqueue(req1)
    }

    try await Task.sleep(nanoseconds: 10_000_000)

    let task2 = Task {
        try await queue.enqueue(req2)
    }

    // Cancel 2
    if let id = Mirror(reflecting: task2).descendant("result", "id") as? UUID {
        await queue.cancelRequest(id: id)
    }

    let res1 = await task1.result
    let res2 = await task2.result
    
    let response1 = try res1.get()
    XCTAssertEqual(response1.statusCode, 200)

    switch res2 {
    case .failure(let e):
        XCTAssertTrue(e is NetworkError)
    default:
        XCTFail()
    }
}
