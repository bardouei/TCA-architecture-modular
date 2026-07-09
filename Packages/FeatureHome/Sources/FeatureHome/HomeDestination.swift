//
//  HomeDestination.swift
//  FeatureHome
//
//  Created by baner on 1/3/26.
//

import ComposableArchitecture
import PostDetailFeature

extension HomeFeature {

    @Reducer
    public enum Destination {
        case postDetail(PostDetailFeature)
    }
}

extension HomeFeature.Destination.State: Equatable {}
