# AppFeature

AppFeature is the application's logical composition root. It composes FeatureSplash and FeatureHome and coordinates root flow without implementing networking or persistence.

```text
AppFeature.State.destination
    .splash(SplashFeature.State)
        | .finished
        v
    .home(HomeFeature.State)
```

The child destination reducer runs before the parent transition reducer so the Splash feature can process `.finished` while its state is still present. `AppView` uses enum case scoping to render the matching child view.

```swift
@main
struct MyApp: App {
    private let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup { AppView(store: store) }
    }
}
```

The store must have stable identity and must not be recreated inside `body`. Add new root destinations to the destination enum, reducer transition, and AppView switch together.

The Modules tab hosts an executable showcase for DesignSystem, NetworkCore, and StorageCore. It also exposes System, Light, and Dark appearance selection.
