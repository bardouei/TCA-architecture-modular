//
//  HomeDestination.swift
//  AppFeature
//
//  Created by baner on 1/3/26.
//

import ComposableArchitecture

extension HomeFeature {

    @Reducer
    public enum Destination {
        case postDetail(PostDetail)
    }
}

extension HomeFeature.Destination.State: Equatable {}
