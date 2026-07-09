//
//  HomeAction.swift
//  FeatureHome
//
//  Created by baner on 1/3/26.
//

import ComposableArchitecture
import DomainCore

extension HomeFeature {

    @CasePathable
    public enum Action {
        case onAppear
        case postsLoaded([EntityPost])
        case postTapped(EntityPost)
        case path(StackAction<Destination.State, Destination.Action>)
    }
}
