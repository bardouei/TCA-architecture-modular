import ComposableArchitecture

@Reducer
public struct ProductDetailFeature {
    public init() {}
    @ObservableState public struct State: Equatable {
        public let product: Product
        public var isFavorite = false
        public init(product: Product) { self.product = product }
    }
    public enum Action: Equatable { case favoriteTapped }
    public var body: some ReducerOf<Self> {
        Reduce { state, _ in state.isFavorite.toggle(); return .none }
    }
}
