import AppDependencies
import ComposableArchitecture
import DomainCore
import Foundation
import NetworkCore

public struct AppClipPostClient: Sendable {
    public var fetchPost: @Sendable (Int) async throws -> EntityPost

    public init(fetchPost: @escaping @Sendable (Int) async throws -> EntityPost) {
        self.fetchPost = fetchPost
    }
}

private enum AppClipPostClientKey: DependencyKey {
    static let liveValue = AppClipPostClient { id in
        @Dependency(\.networkClient) var networkClient
        let response = try await networkClient.send(NetworkRequest(path: "/posts/\(id)"))
        return try response.decode(EntityPost.self)
    }

    static let testValue = AppClipPostClient { _ in
        throw NetworkError.invalidRequest
    }
}

public extension DependencyValues {
    var appClipPostClient: AppClipPostClient {
        get { self[AppClipPostClientKey.self] }
        set { self[AppClipPostClientKey.self] = newValue }
    }
}

@Reducer
public struct AppClipFeature {
    public enum Failure: Equatable, Sendable {
        case connection
        case invalidData
        case unavailable
    }

    @ObservableState
    public struct State: Equatable {
        public var postId: Int
        public var post: EntityPost?
        public var isLoading: Bool
        public var failure: Failure?

        public init(
            postId: Int,
            post: EntityPost? = nil,
            isLoading: Bool = false,
            failure: Failure? = nil
        ) {
            self.postId = postId
            self.post = post
            self.isLoading = isLoading
            self.failure = failure
        }
    }

    public enum Action: Equatable, Sendable {
        case task
        case retryTapped
        case invocationURLReceived(URL)
        case cancelLoading
        case postResponse(TaskResult<EntityPost>)
    }

    @Dependency(\.appClipPostClient) var postClient

    private nonisolated enum CancelID: Hashable, Sendable {
        case loadPost
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task, .retryTapped:
                state.isLoading = true
                state.failure = nil
                let id = state.postId
                let postClient = self.postClient
                return .run { send in
                    await send(.postResponse(TaskResult { try await postClient.fetchPost(id) }))
                }
                .cancellable(id: CancelID.loadPost, cancelInFlight: true)

            case let .invocationURLReceived(url):
                guard let postId = AppClipInvocation.postID(from: url), postId != state.postId else {
                    return .none
                }
                state.postId = postId
                state.post = nil
                return .send(.task)

            case .cancelLoading:
                state.isLoading = false
                return .cancel(id: CancelID.loadPost)

            case let .postResponse(.success(post)):
                state.post = post
                state.isLoading = false
                state.failure = nil
                return .none

            case let .postResponse(.failure(error)):
                state.isLoading = false
                if error is DecodingError {
                    state.failure = .invalidData
                } else if let networkError = error as? NetworkError, networkError.isConnectionError {
                    state.failure = .connection
                } else {
                    state.failure = .unavailable
                }
                return .none
            }
        }
    }
}

public enum AppClipInvocation {
    public static func postID(from url: URL) -> Int? {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let value = components.queryItems?
            .first(where: { $0.name == "postId" || $0.name == "id" })?.value,
           let postID = Int(value), postID > 0 {
            return postID
        }

        guard let value = url.pathComponents.last,
              let postID = Int(value), postID > 0 else {
            return nil
        }
        return postID
    }
}
