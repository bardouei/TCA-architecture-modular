//
//  URLRequest+Extensions.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

extension URLRequest {
    public mutating func addHeaders(_ headers: [HTTPHeader]) {
        headers.forEach { self.addValue($0.value, forHTTPHeaderField: $0.name) }
    }
    
    public mutating func setJSONBody<T: Encodable>(_ body: T, encoder: JSONEncoder = JSONEncoder()) throws {
        httpBody = try encoder.encode(body)
        setValue(HTTPHeader.ContentType.json, forHTTPHeaderField: "Content-Type")
    }
    
    public mutating func setFormURLEncodedBody(_ parameters: [String: String]) {
        let bodyString = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        
        httpBody = bodyString.data(using: .utf8)
        setValue(HTTPHeader.ContentType.formUrlEncoded, forHTTPHeaderField: "Content-Type")
    }
}
