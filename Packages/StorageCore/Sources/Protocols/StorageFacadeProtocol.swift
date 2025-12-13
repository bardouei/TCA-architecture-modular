//
//  StorageFacadeProtocol.swift
//  Storage
//
//  Created by baner on 12/12/25.
//

import Foundation

public protocol StorageFacadeProtocol: Sendable {
    var preferences: KeyValueStore { get }
    var secure: SecureStore { get }
    var database: DatabaseStore { get }
}
