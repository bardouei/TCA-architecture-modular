//
//  StorageFacade.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public final class StorageFacade: StorageFacadeProtocol {

    public let preferences: KeyValueStore
    public let secure: SecureStore
    public let database: DatabaseStore

    public init(
        preferences: KeyValueStore,
        secure: SecureStore,
        database: DatabaseStore
    ) {
        self.preferences = preferences
        self.secure = secure
        self.database = database
    }
}
