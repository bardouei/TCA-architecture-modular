//
//  RequestBuilder.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public actor RequestBuilder: RequestBuilderProtocol {
    
    private let configuration: URLSessionNetworkClient.NetworkConfiguration?
    
    public init(
        configuration: URLSessionNetworkClient.NetworkConfiguration? = nil
    ) {
        self.configuration = configuration
    }
    
    public func build(from request: NetworkRequest) async throws -> URLRequest {

        let baseURL = request.baseURL ?? configuration?.baseURL

        guard let baseURL else {
            throw NetworkError.invalidURL
        }

        if let pathComponents = URLComponents(string: request.path),
           pathComponents.scheme != nil || pathComponents.host != nil {
            throw NetworkError.invalidURL
        }

        guard var components = URLComponents(
            url: URL(string: request.path, relativeTo: baseURL)?.absoluteURL ?? baseURL,
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        if let queryParameters = request.queryParameters, !queryParameters.isEmpty {
            components.queryItems = queryParameters
                .sorted { $0.key < $1.key }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeoutInterval
        urlRequest.cachePolicy = request.cachePolicy

        request.headers.forEach {
            urlRequest.addValue($0.value, forHTTPHeaderField: $0.name)
        }

        urlRequest.httpBody = request.body

        return urlRequest
    }
    
    public func buildMultipart(from request: NetworkRequest, multipartData: MultipartFormData) async throws -> URLRequest {
        var urlRequest = try await build(from: request)
        
        // Set multipart content type
        urlRequest.setValue(multipartData.contentType, forHTTPHeaderField: "Content-Type")
        
        // Build multipart body
        let bodyData = try await buildMultipartBody(multipartData)
        urlRequest.httpBody = bodyData
        
        return urlRequest
    }
    
    private func buildMultipartBody(
        _ multipartData: MultipartFormData
    ) async throws -> Data {

        let maximumInMemoryBodySize = 20 * 1_024 * 1_024
        var body = Data()
        body.reserveCapacity(min(maximumInMemoryBodySize, 1_024 * 1_024))
        let boundary = multipartData.boundary

        for part in multipartData.parts {

            body.appendString("--\(boundary)\r\n")

            switch part {

            case .text(let text, let name):
                body.appendString(
                    "Content-Disposition: form-data; name=\"\(try sanitizedHeaderValue(name))\"\r\n\r\n"
                )
                body.appendString("\(text)\r\n")

            case .data(let data, let fileName, let mimeType, let name):
                let safeName = try sanitizedHeaderValue(name)
                let safeFileName = try sanitizedHeaderValue(fileName)
                let safeMIMEType = try sanitizedHeaderValue(mimeType)
                guard body.count + data.count <= maximumInMemoryBodySize else {
                    throw NetworkError.payloadTooLarge
                }
                body.appendString(
                    """
                    Content-Disposition: form-data; name="\(safeName)"; filename="\(safeFileName)"\r\n
                    Content-Type: \(safeMIMEType)\r\n\r\n
                    """
                )
                body.append(data)
                body.appendString("\r\n")

            case .file(let fileURL, let fileName, let mimeType, let name):
                let safeName = try sanitizedHeaderValue(name)
                let safeFileName = try sanitizedHeaderValue(fileName)
                let safeMIMEType = try sanitizedHeaderValue(mimeType)
                let fileSize = try fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                guard fileSize <= maximumInMemoryBodySize - body.count else {
                    throw NetworkError.payloadTooLarge
                }
                let fileData = try Data(contentsOf: fileURL, options: .mappedIfSafe)

                body.appendString(
                    """
                    Content-Disposition: form-data; name="\(safeName)"; filename="\(safeFileName)"\r\n
                    Content-Type: \(safeMIMEType)\r\n\r\n
                    """
                )
                body.append(fileData)
                body.appendString("\r\n")
            }
        }

        body.appendString("--\(boundary)--\r\n")
        guard body.count <= maximumInMemoryBodySize else {
            throw NetworkError.payloadTooLarge
        }
        return body
    }

    private func sanitizedHeaderValue(_ value: String) throws -> String {
        guard !value.contains("\r"), !value.contains("\n"), !value.contains("\"") else {
            throw NetworkError.invalidRequestBody
        }
        return value
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        append(Data(string.utf8))
    }
}
