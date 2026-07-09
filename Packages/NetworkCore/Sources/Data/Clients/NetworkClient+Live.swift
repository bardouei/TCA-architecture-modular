//
//  NetworkClient+Live.swift
//  NetworkCore
//
//  Created by baner on 1/3/26.
//

import Foundation

public extension AnyNetworkClient {

    static let live = AnyNetworkClient(
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
