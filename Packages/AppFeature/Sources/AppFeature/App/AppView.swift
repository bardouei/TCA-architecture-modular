import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct AppView: View {
    @Bindable private var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        switch store.scope(state: \.destination, action: \.destination).case {
        case let .splash(splashStore):
            SplashView(store: splashStore)
        case let .main(mainStore):
            MainContentView(store: mainStore)
        }
    }
}

private struct MainContentView: View {
    let store: StoreOf<AppFeature.MainFeature>

    var body: some View {
        TabView {
            HomeView(store: store.scope(state: \.home, action: \.home))
                .tabItem { Label("Home", systemImage: "house") }

            CatalogView(store: store.scope(state: \.catalog, action: \.catalog))
                .tabItem { Label("Explore", systemImage: "square.grid.2x2") }

            ModuleShowcaseView()
                .tabItem { Label("Modules", systemImage: "shippingbox") }
        }
        .tint(DSColor.primary)
    }
}
