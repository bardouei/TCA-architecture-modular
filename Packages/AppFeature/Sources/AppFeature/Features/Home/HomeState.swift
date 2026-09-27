//
//  HomeState.swift
//  AppFeature
//
//  Created by baner on 1/3/26.
//

import ComposableArchitecture
import DomainCore

extension HomeFeature {

    public enum LoadFailure: Equatable, Sendable {
        case connection
        case invalidData
        case unavailable
    }

    @ObservableState
    public struct State: Equatable {
        public var posts: [EntityPost] = []
        public var isLoading: Bool = false
        public var failure: LoadFailure?
        public var path = StackState<Destination.State>()

        public init() {}
    }
}
