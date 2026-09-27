import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct CatalogView: View {
    @Bindable private var store: StoreOf<CatalogFeature>
    public init(store: StoreOf<CatalogFeature>) { self.store = store }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Group {
                if let failure = store.failure {
                    ContentUnavailableView {
                        Label("Products unavailable", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(message(for: failure))
                    } actions: {
                        Button("Retry") { store.send(.refresh) }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: DSSpacing.md) {
                            ForEach(store.products) { product in
                                ProductCard(product: product) { store.send(.productTapped(product)) }
                            }
                        }.padding(DSSpacing.md)
                    }.refreshable { await store.send(.refresh).finish() }
                }
            }
            .overlay { if store.isLoading { DSLoadingView() } }
            .navigationTitle("Explore")
            .searchable(text: Binding(
                get: { store.searchQuery },
                set: { store.send(.searchQueryChanged($0)) }
            ), prompt: "Search products")
            .task {
                guard store.products.isEmpty else { return }
                await store.send(.task).finish()
            }
        } destination: { store in
            switch store.case { case let .detail(store): ProductDetailView(store: store) }
        }
    }

    private func message(for failure: CatalogFeature.Failure) -> LocalizedStringResource {
        switch failure {
        case .connection: "Check your connection and try again."
        case .invalidData: "The server response could not be read."
        case .unavailable: "The catalog is temporarily unavailable."
        }
    }
}

private struct ProductCard: View {
    let product: Product
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    AsyncImage(url: product.thumbnail) { image in image.resizable().scaledToFit() } placeholder: { ProgressView() }
                        .frame(maxWidth: .infinity).frame(height: 130)
                    Text(product.title).font(DSTypography.headline).foregroundStyle(DSColor.textPrimary).lineLimit(2)
                    Text(product.price, format: .currency(code: "USD")).foregroundStyle(DSColor.primary)
                    Label(product.rating.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                        .font(DSTypography.caption).foregroundStyle(DSColor.warning)
                }
            }
        }.buttonStyle(.plain).accessibilityElement(children: .combine).accessibilityHint("Opens product details")
    }
}
