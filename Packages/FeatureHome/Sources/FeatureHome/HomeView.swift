//
//  HomeView.swift
//  FeatureHome
//
//  Created by baner on 12/12/25.
//

import SwiftUI
import ComposableArchitecture
import PostDetailFeature
import DomainCore
import DesignSystem

public struct HomeView: View {
    
    let store: StoreOf<HomeFeature>
    
    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: \.path)
        ) {
            
            ZStack {
                content
                    .animation(.easeInOut, value: store.posts)
                
                if store.isLoading {
                    loadingOverlay
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.send(.onAppear)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            
        } destination: { store in
            switch store.case {
            case let .postDetail(store):
                PostDetailView(store: store)
            }
        }
    }
}

private extension HomeView {
    
    @ViewBuilder
    var content: some View {
        if let error = store.error {
            errorView(message: error)
        } else if store.posts.isEmpty && !store.isLoading {
            emptyView
        } else {
            postsList
        }
    }
}

private extension HomeView {
    
    var postsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(store.posts) { post in
                    postCard(post)
                        .onTapGesture {
                            store.send(.postTapped(post))
                        }
                }
            }
            .padding()
        }
        .refreshable {
            store.send(.onAppear)
        }
    }
    
    func postCard(_ post: EntityPost) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text(post.title)
                    .font(DSTypography.title)
                    .foregroundStyle(DSColor.primary)
                
                Text(post.body)
                    .font(DSTypography.body)
                    .foregroundStyle(DSColor.primary)
                    .lineLimit(3)
            }
        }
    }
}


private extension HomeView {

    var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()

            if store.isLoading {
                DSLoadingView()
            }
        }
    }
}

private extension HomeView {
    
    var emptyView: some View {
        DSEmptyStateView(title: "No Posts", description: "No Posts")
    }
}

private extension HomeView {
    
    func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry") {
                store.send(.onAppear)
            }
        }
    }
}
