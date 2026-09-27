import ComposableArchitecture
import Foundation
@testable import AppFeature
import Testing

@MainActor
struct CatalogFeatureTests {
    @Test func `Task loads products`() async {
        let product = makeProduct()
        let store = TestStore(initialState: CatalogFeature.State()) {
            CatalogFeature()
        } withDependencies: {
            $0.catalogClient.fetchProducts = { _ in [product] }
        }

        await store.send(.task) {
            $0.isLoading = true
            $0.failure = nil
        }
        await store.receive(\.response) {
            $0.products = [product]
            $0.isLoading = false
        }
    }

    @Test func `Product tap pushes detail`() async {
        let product = makeProduct()
        let store = TestStore(initialState: CatalogFeature.State()) {
            CatalogFeature()
        }

        await store.send(.productTapped(product)) {
            $0.path.append(.detail(.init(product: product)))
        }
    }

    @Test func `Favorite tap toggles state`() async {
        let product = makeProduct()
        let store = TestStore(initialState: ProductDetailFeature.State(product: product)) {
            ProductDetailFeature()
        }

        await store.send(.favoriteTapped) {
            $0.isFavorite = true
        }
    }

    private func makeProduct() -> Product {
        Product(
            id: 1,
            title: "Sample",
            description: "Description",
            category: "demo",
            price: 10,
            rating: 4.5,
            stock: 2,
            thumbnail: URL(string: "https://example.com/thumbnail.jpg")!,
            images: [URL(string: "https://example.com/image.jpg")!]
        )
    }
}
