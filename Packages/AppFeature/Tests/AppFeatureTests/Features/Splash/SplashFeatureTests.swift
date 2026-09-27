//
//  SplashFeatureTests.swift
//  AppFeature
//

import ComposableArchitecture
@testable import AppFeature
import Testing

@MainActor
struct SplashFeatureTests {
    @Test func `On appear finishes after delay`() async {
        let clock = TestClock()
        let store = TestStore(initialState: SplashFeature.State()) {
            SplashFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.onAppear)
        await clock.advance(by: .seconds(2))
        await store.receive(.finished)
    }

    @Test func `On disappear cancels timer`() async {
        let clock = TestClock()
        let store = TestStore(initialState: SplashFeature.State()) {
            SplashFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.onAppear)
        await store.send(.onDisappear)
        await clock.advance(by: .seconds(2))
    }
}
