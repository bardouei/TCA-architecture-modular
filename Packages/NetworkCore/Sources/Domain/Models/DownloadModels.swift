//
//  DownloadModels.swift
//  Networking
//
//  Created by baner on 12/10/25.
//

import Foundation

public struct DownloadRequest: Sendable {
    public let url: URL
    public let destinationURL: URL
    public let headers: [HTTPHeader]
    public let resumeData: Data?
    
    public init(
        url: URL,
        destinationURL: URL,
        headers: [HTTPHeader] = [],
        resumeData: Data? = nil
    ) {
        self.url = url
        self.destinationURL = destinationURL
        self.headers = headers
        self.resumeData = resumeData
    }
}

public struct DownloadResponse: Sendable {
    public let request: DownloadRequest
    public let localURL: URL
    public let response: URLResponse?
    public let progress: Double
    
    public init(
        request: DownloadRequest,
        localURL: URL,
        response: URLResponse?,
        progress: Double
    ) {
        self.request = request
        self.localURL = localURL
        self.response = response
        self.progress = progress
    }
}

public struct DownloadProgress: Sendable {
    public let request: DownloadRequest
    public let bytesWritten: Int64
    public let totalBytesWritten: Int64
    public let totalBytesExpectedToWrite: Int64
    public let progress: Double
    
    public init(
        request: DownloadRequest,
        bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        self.request = request
        self.bytesWritten = bytesWritten
        self.totalBytesWritten = totalBytesWritten
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        self.progress = totalBytesExpectedToWrite > 0 ?
            Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) : 0
    }
}
