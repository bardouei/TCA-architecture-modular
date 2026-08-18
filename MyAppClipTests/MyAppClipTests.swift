//
//  MyAppClipTests.swift
//  MyAppClipTests
//

import ComposableArchitecture
import DomainCore
@testable import MyAppClip
import XCTest

@MainActor
final class MyAppClipTests: XCTestCase {
    func testOnAppearLoadsPost() async {
        let post = EntityPost(id: 2, title: "Title", body: "Body")
        let store = TestStore(initialState: AppClipFeature.State(postId: 2)) {
            AppClipFeature()
        } withDependencies: {
            $0.appClipPostClient.fetchPost = { id in
                XCTAssertEqual(id, 2)
                return post
            }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(\.postResponse) {
            $0.post = post
            $0.isLoading = false
            $0.error = nil
        }
    }

    func testOnAppearStoresError() async {
        let store = TestStore(initialState: AppClipFeature.State(postId: 2)) {
            AppClipFeature()
        } withDependencies: {
            $0.appClipPostClient.fetchPost = { _ in
                throw TestError.failed
            }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
            $0.error = nil
        }

        await store.receive(\.postResponse) {
            $0.isLoading = false
            $0.error = "Failed to load post"
        }
    }
}

private enum TestError: LocalizedError {
    case failed

    var errorDescription: String? {
        "Failed to load post"
    }
}
