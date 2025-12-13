//
//  LoadAuthTokenUseCase.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public protocol LoadAuthTokenUseCase {
    func execute() async throws -> String
}

public final class DefaultLoadAuthTokenUseCase: LoadAuthTokenUseCase {

    private let secureStore: SecureStore

    public init(secureStore: SecureStore) {
        self.secureStore = secureStore
    }

    public func execute() async throws -> String {
        let data = try await secureStore.load(for: StorageKeys.Auth.token)
        return String(decoding: data, as: UTF8.self)
    }
}
