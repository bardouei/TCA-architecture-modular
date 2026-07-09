//
//  HomeState.swift
//  FeatureHome
//
//  Created by baner on 1/3/26.
//

import ComposableArchitecture
import DomainCore

extension HomeFeature {

    @ObservableState
    public struct State: Equatable {
        public var posts: [EntityPost] = []
        public var isLoading: Bool = false
        public var error: String?
        public var path = StackState<Destination.State>()

        public init() {}
    }
}
