//
//  CoreError.swift
//  BaseCore
//
//  Created by baner on 12/12/25.
//

import Foundation

public enum CoreError: Error, Equatable, Sendable {
    case unknown
    case invalidURL
    case decodingFailed
}

extension CoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            "An unknown error occurred."
        case .invalidURL:
            "The URL is invalid."
        case .decodingFailed:
            "The received data could not be decoded."
        }
    }
}
