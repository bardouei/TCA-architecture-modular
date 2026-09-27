import ComposableArchitecture

extension AppFeature {
    @Reducer
    public struct MainFeature {
        public init() {}

        @ObservableState
        public struct State: Equatable {
            public var home = HomeFeature.State()
            public var catalog = CatalogFeature.State()

            public init() {}
        }

        @CasePathable
        public enum Action {
            case home(HomeFeature.Action)
            case catalog(CatalogFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.home, action: \.home) {
                HomeFeature()
            }
            Scope(state: \.catalog, action: \.catalog) {
                CatalogFeature()
            }
        }
    }
}
