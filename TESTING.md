# Testing Strategy

## Tools

- Unit tests: Swift Testing (`import Testing`, `@Test`)
- UI tests: XCTest and XCUIAutomation
- TCA reducers: `TestStore`, deterministic dependencies, and virtual clocks

## Test pyramid

1. Base and domain models/use cases: fast tests without I/O.
2. Network and storage: contract tests and controlled integration tests.
3. Reducers: state transitions, effects, failure mapping, navigation, and cancellation.
4. A small number of UI tests for critical application and App Clip flows.

## Stability rules

- Unit tests never depend on the live internet, wall-clock delays, or a shared Keychain service.
- Every test uses an isolated namespace, storage suite, or service and cleans up afterward.
- Clocks, UUID generation, and clients are injected.
- Async tests have a deterministic completion path and do not leave unowned tasks running.
- Point-Free package versions must be consistent across all local packages.

## TCA package compatibility

This project pins TCA 1.26.2, swift-dependencies 1.17.1, and xctest-dynamic-overlay 1.13.0. Older overlay versions conflict with swift-issue-reporting and are incompatible with newer Swift Testing internals. Library packages should not keep independent `Package.resolved` files; the Xcode workspace owns the resolved dependency graph.
