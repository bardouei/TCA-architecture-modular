//
//  RequestBuilder.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public actor RequestBuilder: RequestBuilderProtocol {
    
    private let configuration: URLSessionNetworkClient.NetworkConfiguration
    
    public init(
        configuration: URLSessionNetworkClient.NetworkConfiguration
    ) {
        self.configuration = configuration
    }
    
    public func build(from request: NetworkRequest) async throws -> URLRequest {

        guard let url = URL(
            string: request.path,
            relativeTo: configuration.baseURL
        )?.absoluteURL else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = configuration.timeoutInterval
        urlRequest.cachePolicy = configuration.cachePolicy

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

        var body = Data()
        let boundary = multipartData.boundary

        for part in multipartData.parts {

            body.appendString("--\(boundary)\r\n")

            switch part {

            case .text(let text, let name):
                body.appendString(
                    "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
                )
                body.appendString("\(text)\r\n")

            case .data(let data, let fileName, let mimeType, let name):
                body.appendString(
                    """
                    Content-Disposition: form-data; name="\(name)"; filename="\(fileName)"\r\n
                    Content-Type: \(mimeType)\r\n\r\n
                    """
                )
                body.append(data)
                body.appendString("\r\n")

            case .file(let fileURL, let fileName, let mimeType, let name):
                let fileData = try Data(contentsOf: fileURL)

                body.appendString(
                    """
                    Content-Disposition: form-data; name="\(name)"; filename="\(fileName)"\r\n
                    Content-Type: \(mimeType)\r\n\r\n
                    """
                )
                body.append(fileData)
                body.appendString("\r\n")
            }
        }

        body.appendString("--\(boundary)--\r\n")
        return body
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        append(Data(string.utf8))
    }
}
