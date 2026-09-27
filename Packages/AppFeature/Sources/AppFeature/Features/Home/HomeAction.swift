//
//  HomeAction.swift
//  AppFeature
//
//  Created by baner on 1/3/26.
//

import ComposableArchitecture
import DomainCore

extension HomeFeature {

    @CasePathable
    public enum Action {
        case task
        case refresh
        case retryTapped
        case cancelLoading
        case postsResponse(TaskResult<[EntityPost]>)
        case postTapped(EntityPost)
        case path(StackAction<Destination.State, Destination.Action>)
    }
}
