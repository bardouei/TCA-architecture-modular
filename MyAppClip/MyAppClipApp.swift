//
//  MyAppClipApp.swift
//  MyAppClip
//
//  Created by baner on 2/1/26.
//

import SwiftUI
import ComposableArchitecture
import DomainCore
import AppClipFeature

struct AppClipView: View {
    @Bindable var store: StoreOf<AppClipFeature>

    var body: some View {
        AppClipContentView(
            post: store.post,
            isLoading: store.isLoading,
            failure: store.failure,
            onRetry: { store.send(.retryTapped) }
        )
        .task {
            guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else {
                return
            }
            await store.send(.task).finish()
        }
        .onOpenURL { url in
            store.send(.invocationURLReceived(url))
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            if let url = activity.webpageURL {
                store.send(.invocationURLReceived(url))
            }
        }
        .onDisappear {
            store.send(.cancelLoading)
        }
    }
}

private struct AppClipContentView: View {
    let post: EntityPost?
    let isLoading: Bool
    let failure: AppClipFeature.Failure?
    let onRetry: () -> Void

    var body: some View {
        if isLoading {
            ProgressView("Loading…")
        } else if let failure {
            ContentUnavailableView {
                Label("Unable to Load Post", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message(for: failure))
            } actions: {
                Button("Retry", action: onRetry)
            }
        } else if let post {
            AppClipPostView(title: post.title, bodyText: post.body)
        } else {
            ContentUnavailableView("Post Not Found", systemImage: "doc.text.magnifyingglass")
        }
    }

    private func message(for failure: AppClipFeature.Failure) -> LocalizedStringResource {
        switch failure {
        case .connection:
            "Check your internet connection and try again."
        case .invalidData:
            "The post data could not be read."
        case .unavailable:
            "This post is temporarily unavailable."
        }
    }
}

private struct AppClipPostView: View {
    let title: String
    let bodyText: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(bodyText)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }
}
