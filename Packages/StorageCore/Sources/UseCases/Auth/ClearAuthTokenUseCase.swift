//
//  ClearAuthTokenUseCase.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public protocol ClearAuthTokenUseCase {
    func execute() async throws
}

public final class DefaultClearAuthTokenUseCase: ClearAuthTokenUseCase {

    private let secureStore: SecureStore

    public init(secureStore: SecureStore) {
        self.secureStore = secureStore
    }

    public func execute() async throws {
        try await secureStore.delete(for: StorageKeys.Auth.token)
    }
}
