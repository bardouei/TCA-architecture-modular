//
//  PostDetail.swift
//  AppFeature
//
//  Created by baner on 12/17/25.
//

import ComposableArchitecture
import Foundation
import DomainCore

@Reducer
public struct PostDetail {

    public init() {}

    @ObservableState
    public struct State: Equatable, Identifiable {
        public let post: EntityPost
        public var id: Int { post.id }

        public init(post: EntityPost) {
            self.post = post
        }
    }

    public enum Action {
        case onCloseTapped
    }

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onCloseTapped:
                return .none
            }
        }
    }
}
