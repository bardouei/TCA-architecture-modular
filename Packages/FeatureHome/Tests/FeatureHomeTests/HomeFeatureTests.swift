//
//  HomeFeatureTests.swift
//  FeatureHome
//

import ComposableArchitecture
import DomainCore
@testable import FeatureHome
import PostDetailFeature
import XCTest

@MainActor
final class HomeFeatureTests: XCTestCase {
    func testOnAppearLoadsPosts() async {
        let posts = [
            EntityPost(id: 1, title: "First", body: "Body")
        ]

        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = { posts }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(\.postsResponse) {
            $0.isLoading = false
            $0.posts = posts
            $0.error = nil
        }
    }

    func testOnAppearStoresErrorMessage() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = {
                throw TestError.failed
            }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(\.postsResponse) {
            $0.isLoading = false
            $0.error = "Failed to load posts"
        }
    }

    func testPostTappedPushesPostDetail() async {
        let post = EntityPost(id: 42, title: "Title", body: "Body")
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }

        await store.send(.postTapped(post)) {
            $0.path.append(.postDetail(PostDetailFeature.State(post: post)))
        }
    }
}

private enum TestError: LocalizedError {
    case failed

    var errorDescription: String? {
        "Failed to load posts"
    }
}
