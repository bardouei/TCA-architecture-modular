//
//  StorageError.swift.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

public enum StorageError: Error, Equatable {

    case notFound
    case invalidKey
    case encoding
    case decoding
    case underlying(String)

    public static func == (lhs: StorageError, rhs: StorageError) -> Bool {
        switch (lhs, rhs) {

        case (.notFound, .notFound),
             (.invalidKey, .invalidKey),
             (.encoding, .encoding),
             (.decoding, .decoding):
            return true

        case let (.underlying(a), .underlying(b)):
            return a == b

        default:
            return false
        }
    }
}
