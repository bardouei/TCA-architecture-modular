import ComposableArchitecture

@Reducer
public struct AppFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var destination: Destination.State

        public init() {
            self.destination = .splash(.init())
        }
    }

    @Reducer
    public enum Destination {
        case splash(SplashFeature)
        case main(MainFeature)
    }

    @CasePathable
    public enum Action {
        case destination(Destination.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.destination, action: \.destination) {
            Destination.body
        }
        Reduce { state, action in
            switch action {
            case .destination(.splash(.finished)):
                state.destination = .main(.init())
                return .none

            case .destination:
                return .none
            }
        }
    }
}

extension AppFeature.Destination.State: Equatable {}
