//
//  SaveAuthTokenUseCase.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public protocol SaveAuthTokenUseCase {
    func execute(token: String) async throws
}

public final class DefaultSaveAuthTokenUseCase: SaveAuthTokenUseCase {

    private let secureStore: SecureStore

    public init(secureStore: SecureStore) {
        self.secureStore = secureStore
    }

    public func execute(token: String) async throws {
        let data = Data(token.utf8)
        try await secureStore.save(data, for: StorageKeys.Auth.token)
    }
}
