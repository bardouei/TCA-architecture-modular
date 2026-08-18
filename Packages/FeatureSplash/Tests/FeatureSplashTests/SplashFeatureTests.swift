//
//  SplashFeatureTests.swift
//  FeatureSplash
//

import ComposableArchitecture
@testable import FeatureSplash
import XCTest

@MainActor
final class SplashFeatureTests: XCTestCase {
    func testOnAppearFinishesAfterDelay() async {
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

    func testOnDisappearCancelsTimer() async {
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
