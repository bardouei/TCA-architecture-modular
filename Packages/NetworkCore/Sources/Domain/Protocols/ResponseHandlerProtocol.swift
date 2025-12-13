//
//  ResponseHandlerProtocol.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public protocol ResponseHandlerProtocol: Sendable {
    func handle(
        data: Data,
        response: URLResponse,
        request: NetworkRequest
    ) async throws -> NetworkResponse
    
    func validate(_ response: NetworkResponse) throws
}
