//
//  TCAAdapters.swift
//  TCAAdapters
//
//  Created by baner on 12/13/25.
//

import ComposableArchitecture
import NetworkCore
import Foundation

private enum NetworkClientKey: DependencyKey {
    static let liveValue: AnyNetworkClient = AnyNetworkClient(
        URLSessionNetworkClient(
            configuration: .live,
            session: URLSession.shared,
            interceptors: [],
            responseHandler: DefaultResponseHandler(),
            requestBuilder: RequestBuilder(configuration: .live),
            logger: NetworkLogger()
        )
    )
}

extension DependencyValues {
    public var networkClient: AnyNetworkClient {
        get { self[NetworkClientKey.self] }
        set { self[NetworkClientKey.self] = newValue }
    }
}
