//
//  AppFeatureTests.swift
//  AppFeature
//

@testable import AppFeature
import ComposableArchitecture
import FeatureHome
import Testing

struct AppFeatureTests {
    @Test func `Splash completion transitions atomically to home`() async {
        await splashCompletionTransitionsAtomicallyToHome()
    }

    @MainActor
    private func splashCompletionTransitionsAtomicallyToHome() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.destination(.splash(.finished))) {
            $0.destination = .home(HomeFeature.State())
        }
    }
}
