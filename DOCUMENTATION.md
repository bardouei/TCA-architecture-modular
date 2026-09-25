# Architecture and Module Guide

This project uses modular architecture, SwiftUI, Swift Concurrency, and The Composable Architecture (TCA). Dependencies flow from application features toward lower-level contracts. Core modules never import feature modules.

```text
TCAtest / MyAppClip
        |
    AppFeature ---------------------- App Clip Feature
     /      \
Splash    FeatureHome -> PostDetailFeature
              |
        TCAAdapters
          /      \
 NetworkCore   StorageCore
          \      /
          DomainCore
              |
           BaseCore

DesignSystem is consumed by presentation layers.
```

## Module documentation

- [BaseCore](Packages/BaseCore/README.md)
- [DomainCore](Packages/DomainCore/README.md)
- [NetworkCore](Packages/NetworkCore/README.md)
- [StorageCore](Packages/StorageCore/README.md)
- [DesignSystem](Packages/DesignSystem/README.md)
- [TCAAdapters](Packages/TCAAdapters/README.md)
- [FeatureSplash](Packages/FeatureSplash/README.md)
- [FeatureHome](Packages/FeatureHome/README.md)
- [AppFeature](Packages/AppFeature/README.md)
- [App Clip](MyAppClip/README.md)
- [Testing strategy](TESTING.md)

## Shared development rules

1. I/O APIs use async/await, and values crossing concurrency boundaries conform to `Sendable`.
2. Features receive clients through dependency injection instead of constructing live singletons.
3. UI state stores stable, domain-friendly failures rather than raw localized error strings.
4. Navigation state belongs to the owning feature and remains testable.
5. Secrets are stored only in Keychain and are never logged.
6. Views use design tokens instead of scattered colors, spacing, and fonts.
7. New asynchronous behavior should cover success, failure, and cancellation in tests.

## Adding a feature

Define framework-independent models and contracts in DomainCore. Put network or persistence implementations in NetworkCore or StorageCore. Adapt shared clients to TCA in TCAAdapters, implement the reducer and view in a feature package, and compose the feature in AppFeature. AppFeature coordinates flows; it does not contain networking or persistence business logic.
