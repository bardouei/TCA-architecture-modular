# AppDependencies

AppDependencies is the boundary between infrastructure modules and TCA's dependency system. NetworkCore and StorageCore remain independent of TCA, while features avoid constructing live infrastructure clients. The package, product, target, tests, and imports all use the `AppDependencies` name.

## Dependencies

- `DependencyValues.networkClient`: the live `AnyNetworkClient`.
- `DependencyValues.cache`: a closure-based `CacheClient` backed by `DiskCache`.

```swift
@Reducer
struct FeedFeature {
    @Dependency(\.networkClient) var networkClient
    @Dependency(\.cache) var cache
}
```

Override dependencies in tests:

```swift
let store = TestStore(initialState: FeedFeature.State()) {
    FeedFeature()
} withDependencies: {
    $0.networkClient = AnyNetworkClient(MockNetworkClient())
    $0.cache = CacheClient(
        load: { _ in nil },
        save: { _, _ in },
        remove: { _ in }
    )
}
```

Adapters perform wiring and type translation only. They must not contain feature business logic. Keep a feature-specific client beside its only consumer; place shared infrastructure adapters here.
