//
//  AppFeatureTests.swift
//  AppFeature
//

@testable import AppFeature
import ComposableArchitecture
import FeatureHome
import XCTest

@MainActor
final class AppFeatureTests: XCTestCase {
    func testSplashFinishedShowsHomeAndRemovesSplash() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.splash(.finished)) {
            $0.home = HomeFeature.State()
        }

        await store.receive(\.removeSplash) {
            $0.splash = nil
        }
    }
}
