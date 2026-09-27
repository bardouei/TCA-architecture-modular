//
//  NetworkClient+Dependency.swift
//  AppDependencies
//
//  Created by baner on 1/3/26.
//

import ComposableArchitecture
import NetworkCore

// MARK: - DependencyKey
private enum NetworkClientKey: DependencyKey {

    static let liveValue: AnyNetworkClient = .live
}

// MARK: - DependencyValues
public extension DependencyValues {

    var networkClient: AnyNetworkClient {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }
}
