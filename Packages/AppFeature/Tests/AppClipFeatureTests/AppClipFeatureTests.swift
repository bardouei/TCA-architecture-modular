import ComposableArchitecture
import DomainCore
import Foundation
import Testing
@testable import AppClipFeature

@Suite("App Clip feature")
struct AppClipFeatureTests {
    @Test("Task loads a post")
    @MainActor
    func taskLoadsPost() async {
        let post = EntityPost(id: 2, title: "Title", body: "Body")
        let store = TestStore(initialState: AppClipFeature.State(postId: 2)) {
            AppClipFeature()
        } withDependencies: {
            $0.appClipPostClient.fetchPost = { id in
                #expect(id == 2)
                return post
            }
        }

        await store.send(.task) { $0.isLoading = true }
        await store.receive(\.postResponse) {
            $0.post = post
            $0.isLoading = false
        }
    }

    @Test("Task classifies an unknown error")
    @MainActor
    func taskStoresFailure() async {
        let store = TestStore(initialState: AppClipFeature.State(postId: 2)) {
            AppClipFeature()
        } withDependencies: {
            $0.appClipPostClient.fetchPost = { _ in throw TestError.failed }
        }

        await store.send(.task) { $0.isLoading = true }
        await store.receive(\.postResponse) {
            $0.isLoading = false
            $0.failure = .unavailable
        }
    }

    @Test("Invocation parser supports query and path identifiers")
    func invocationParser() {
        #expect(AppClipInvocation.postID(from: URL(string: "https://example.com/clip?postId=42")!) == 42)
        #expect(AppClipInvocation.postID(from: URL(string: "https://example.com/posts/7")!) == 7)
        #expect(AppClipInvocation.postID(from: URL(string: "https://example.com/posts/invalid")!) == nil)
    }
}

private enum TestError: Error {
    case failed
}
