//
//  RequestBuilderProtocol.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public protocol RequestBuilderProtocol: Sendable {
    func build(from request: NetworkRequest) async throws -> URLRequest
    func buildMultipart(from request: NetworkRequest, multipartData: MultipartFormData) async throws -> URLRequest
}
