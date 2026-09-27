//
//  HomeFeatureTests.swift
//  FeatureHome
//

import ComposableArchitecture
import DomainCore
import Foundation
@testable import AppFeature
import Testing

struct HomeFeatureTests {
    @Test func `Task loads posts`() async {
        await taskLoadsPosts()
    }

    @MainActor
    private func taskLoadsPosts() async {
        let posts = [
            EntityPost(id: 1, title: "First", body: "Body")
        ]

        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = { posts }
        }

        await store.send(.task) {
            $0.isLoading = true
            $0.failure = nil
        }

        await store.receive(\.postsResponse) {
            $0.isLoading = false
            $0.posts = posts
            $0.failure = nil
        }
    }

    @Test func `Task stores classified failure`() async {
        await taskStoresClassifiedFailure()
    }

    @MainActor
    private func taskStoresClassifiedFailure() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.postsClient.fetchPosts = {
                throw TestError.failed
            }
        }

        await store.send(.task) {
            $0.isLoading = true
            $0.failure = nil
        }

        await store.receive(\.postsResponse) {
            $0.isLoading = false
            $0.failure = .unavailable
        }
    }

    @Test func `Post tap pushes detail`() async {
        await postTapPushesDetail()
    }

    @MainActor
    private func postTapPushesDetail() async {
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
