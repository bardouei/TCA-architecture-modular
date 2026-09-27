//
//  URLSession+Protocol.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func download(for request: URLRequest) async throws -> (URL, URLResponse)
    func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse)
    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse)
}

public extension URLSessionProtocol {
    func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        try await upload(for: request, from: Data(contentsOf: fileURL))
    }
}

extension URLSession: URLSessionProtocol {
    public func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        return try await download(for: request, delegate: nil)
    }
    
    public func upload(for request: URLRequest, from data: Data) async throws -> (Data, URLResponse) {
        return try await upload(for: request, from: data, delegate: nil)
    }

    public func upload(for request: URLRequest, fromFile fileURL: URL) async throws -> (Data, URLResponse) {
        return try await upload(for: request, fromFile: fileURL, delegate: nil)
    }
}
