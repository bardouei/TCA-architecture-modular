import ComposableArchitecture
import DesignSystem
import DomainCore
import SwiftUI

public struct HomeView: View {
    @Bindable private var store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            HomeContentView(
                posts: store.posts,
                isLoading: store.isLoading,
                failure: store.failure,
                onPostTapped: { store.send(.postTapped($0)) },
                onRetry: { store.send(.retryTapped) },
                onRefresh: { await store.send(.refresh).finish() }
            )
            .navigationTitle("Home")
            .homeNavigationTitleDisplayMode()
            .toolbar {
                ToolbarItem(placement: refreshToolbarPlacement) {
                    Button {
                        store.send(.refresh)
                    } label: {
                        Label {
                            Text("Refresh")
                        } icon: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(store.isLoading)
                }
            }
            .task {
                await store.send(.task).finish()
            }
            .onDisappear {
                store.send(.cancelLoading)
            }
        } destination: { store in
            switch store.case {
            case let .postDetail(store):
                PostDetailView(store: store)
            }
        }
    }

    private var refreshToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }
}

private struct HomeContentView: View {
    let posts: [EntityPost]
    let isLoading: Bool
    let failure: HomeFeature.LoadFailure?
    let onPostTapped: (EntityPost) -> Void
    let onRetry: () -> Void
    let onRefresh: @Sendable () async -> Void

    var body: some View {
        ZStack {
            if let failure {
                HomeErrorView(failure: failure, onRetry: onRetry)
            } else if posts.isEmpty, !isLoading {
                HomeEmptyView()
            } else {
                PostsListView(
                    posts: posts,
                    onPostTapped: onPostTapped,
                    onRefresh: onRefresh
                )
            }

            if isLoading {
                HomeLoadingOverlay()
            }
        }
    }
}

private struct PostsListView: View {
    let posts: [EntityPost]
    let onPostTapped: (EntityPost) -> Void
    let onRefresh: @Sendable () async -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: DSSpacing.md) {
                ForEach(posts) { post in
                    PostRowButton(
                        title: post.title,
                        bodyText: post.body,
                        action: { onPostTapped(post) }
                    )
                }
            }
            .padding()
        }
        .refreshable(action: onRefresh)
    }
}

private struct PostRowButton: View {
    let title: String
    let bodyText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text(title)
                        .font(DSTypography.title)
                        .foregroundStyle(DSColor.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(bodyText)
                        .font(DSTypography.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens post details")
    }
}

private struct HomeLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            DSLoadingView()
        }
        .accessibilityElement(children: .combine)
    }
}

private struct HomeEmptyView: View {
    var body: some View {
        ContentUnavailableView {
            Label {
                Text("No Posts")
            } icon: {
                Image(systemName: "tray")
            }
        } description: {
            Text("Pull to refresh or try again later.")
        }
    }
}

private struct HomeErrorView: View {
    let failure: HomeFeature.LoadFailure
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label {
                Text("Something went wrong")
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
        } description: {
            Text(message)
        } actions: {
            Button(action: onRetry) {
                Text("Retry")
            }
        }
    }

    private var message: LocalizedStringResource {
        switch failure {
        case .connection:
            "Check your internet connection and try again."
        case .invalidData:
            "The received data could not be read."
        case .unavailable:
            "Posts are temporarily unavailable."
        }
    }
}

private extension View {
    @ViewBuilder
    func homeNavigationTitleDisplayMode() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.large)
        #else
        self
        #endif
    }
}
