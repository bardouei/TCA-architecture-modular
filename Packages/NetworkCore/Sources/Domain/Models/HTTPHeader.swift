//
//  HTTPHeader.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public struct HTTPHeader: Sendable, Hashable {
    public let name: String
    public let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    
    // Common headers
    public static func contentType(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Content-Type", value: value)
    }
    
    public static func authorization(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Authorization", value: value)
    }
    
    public static func authorization(bearer token: String) -> HTTPHeader {
        HTTPHeader(name: "Authorization", value: "Bearer \(token)")
    }
    
    public static func accept(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept", value: value)
    }
    
    public static func userAgent(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "User-Agent", value: value)
    }
    
    // Header values
    public struct ContentType {
        public static let json = "application/json"
        public static let formUrlEncoded = "application/x-www-form-urlencoded"
        public static let multipartFormData = "multipart/form-data"
        public static let textPlain = "text/plain"
    }
    
    public struct Accept {
        public static let json = "application/json"
        public static let any = "*/*"
    }
}
