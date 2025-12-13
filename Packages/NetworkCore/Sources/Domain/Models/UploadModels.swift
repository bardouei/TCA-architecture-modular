//
//  UploadModels.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public struct UploadRequest: Sendable {
    public let request: NetworkRequest
    public let fileURL: URL
    public let fileKey: String
    public let mimeType: String
    
    public init(
        request: NetworkRequest,
        fileURL: URL,
        fileKey: String = "file",
        mimeType: String = "application/octet-stream"
    ) {
        self.request = request
        self.fileURL = fileURL
        self.fileKey = fileKey
        self.mimeType = mimeType
    }
}

public struct UploadProgress: Sendable {
    public let request: UploadRequest
    public let bytesSent: Int64
    public let totalBytesSent: Int64
    public let totalBytesExpectedToSend: Int64
    public let progress: Double
    
    public init(
        request: UploadRequest,
        bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        self.request = request
        self.bytesSent = bytesSent
        self.totalBytesSent = totalBytesSent
        self.totalBytesExpectedToSend = totalBytesExpectedToSend
        self.progress = totalBytesExpectedToSend > 0 ?
            Double(totalBytesSent) / Double(totalBytesExpectedToSend) : 0
    }
}
