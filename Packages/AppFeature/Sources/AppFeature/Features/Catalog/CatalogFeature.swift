import ComposableArchitecture
import Foundation
import NetworkCore

@Reducer
public struct CatalogFeature {
    @Dependency(\.catalogClient) private var client
    @Dependency(\.continuousClock) private var clock

    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var products: [Product] = []
        public var searchQuery = ""
        public var isLoading = false
        public var failure: Failure?
        public var path = StackState<Destination.State>()
        public init() {}
    }

    public enum Failure: Equatable, Sendable { case connection, invalidData, unavailable }

    @CasePathable
    public enum Action {
        case task
        case refresh
        case searchQueryChanged(String)
        case response(TaskResult<[Product]>)
        case productTapped(Product)
        case path(StackAction<Destination.State, Destination.Action>)
    }

    @Reducer
    public enum Destination { case detail(ProductDetailFeature) }

    private nonisolated enum CancelID: Hashable, Sendable { case request, search }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task, .refresh:
                state.isLoading = true
                state.failure = nil
                let query = state.searchQuery
                let client = self.client
                return .run { send in
                    await send(.response(TaskResult { try await client.fetchProducts(query) }))
                }.cancellable(id: CancelID.request, cancelInFlight: true)
            case let .searchQueryChanged(query):
                state.searchQuery = query
                let clock = self.clock
                return .run { send in
                    try await clock.sleep(for: .milliseconds(350))
                    await send(.refresh)
                }.cancellable(id: CancelID.search, cancelInFlight: true)
            case let .response(.success(products)):
                state.products = products
                state.isLoading = false
                return .none
            case let .response(.failure(error)):
                state.isLoading = false
                if error is DecodingError { state.failure = .invalidData }
                else if let error = error as? NetworkError, error.isConnectionError { state.failure = .connection }
                else { state.failure = .unavailable }
                return .none
            case let .productTapped(product):
                state.path.append(.detail(.init(product: product)))
                return .none
            case .path:
                return .none
            }
        }.forEach(\.path, action: \.path)
    }
}

extension CatalogFeature.Destination.State: Equatable {}
