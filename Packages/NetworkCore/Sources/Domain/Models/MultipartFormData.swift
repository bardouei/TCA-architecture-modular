//
//  MultipartFormData.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public struct MultipartFormData: Sendable {
    public enum Part: Sendable {
        case data(Data, fileName: String, mimeType: String, name: String)
        case file(URL, fileName: String, mimeType: String, name: String)
        case text(String, name: String)
        
        public var name: String {
            switch self {
            case .data(_, _, _, let name),
                 .file(_, _, _, let name),
                 .text(_, let name):
                return name
            }
        }
    }
    
    public let boundary: String
    public let parts: [Part]
    
    public init(parts: [Part]) {
        self.boundary = "Boundary-\(UUID().uuidString)"
        self.parts = parts
    }
    
    public var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }
}
