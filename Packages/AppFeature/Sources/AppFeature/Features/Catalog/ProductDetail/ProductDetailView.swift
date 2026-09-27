import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct ProductDetailView: View {
    private let store: StoreOf<ProductDetailFeature>

    public init(store: StoreOf<ProductDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                productImages
                productInformation
            }
        }
        .navigationTitle("Product")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var productImages: some View {
        TabView {
            ForEach(store.product.images, id: \.absoluteString) { url in
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            }
        }
        .frame(height: 300)
        .tabViewStyle(.page)
    }

    private var productInformation: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            DSBadge(verbatim: store.product.category.capitalized)
            Text(store.product.title)
                .font(DSTypography.largeTitle)
            Text(store.product.price, format: .currency(code: "USD"))
                .font(DSTypography.title)
                .foregroundStyle(DSColor.primary)
            Text(store.product.description)
                .foregroundStyle(DSColor.textSecondary)
            DSButton(
                store.isFavorite ? "Remove Favorite" : "Add to Favorites",
                systemImage: store.isFavorite ? "heart.slash" : "heart"
            ) {
                store.send(.favoriteTapped)
            }
        }
        .padding(DSSpacing.lg)
    }
}
