# BaseCore

BaseCore is the lowest-level internal package. It contains small, stable, framework-independent primitives that can be reused by every other package.

It must not depend on DomainCore, NetworkCore, StorageCore, DesignSystem, AppDependencies, AppFeature, or TCA.

## Directory structure

```text
Sources/
├── Concurrency/
│   └── LockIsolated.swift
├── Errors/
│   └── CoreError.swift
├── Extensions/
│   ├── Collection+Extensions.swift
│   ├── Date+Extensions.swift
│   ├── Optional+Extensions.swift
│   └── String+Extensions.swift
├── Logging/
│   ├── Logger.swift
│   ├── LogDestination.swift
│   └── LogLevel.swift
└── Utilities/
    └── AppEnvironment.swift
```

## Logging

`Logger` uses a destination abstraction and writes to Apple's unified logging system by default. A custom destination can be injected in tests or specialized applications.

```swift
import BaseCore

let logger = Logger(
    subsystem: "com.example.app",
    category: "Authentication",
    minimumLevel: .info
)

logger.log(.info, "Authentication started")
logger.log(.error, "Authentication failed")
```

Never include access tokens, passwords, secrets, or personal payloads in log messages.

## Lock-isolated state

Use `LockIsolated` for small pieces of synchronous mutable state accessed from multiple threads. Keep related properties in one state value so a mutation remains atomic.

```swift
import BaseCore

struct TransferState {
    var bytesReceived = 0
    var isFinished = false
}

let state = LockIsolated(TransferState())

state.withValue {
    $0.bytesReceived += 128
}
```

Prefer an actor for asynchronous workflows. `LockIsolated` is intended for synchronous callback APIs where awaiting is not possible.

## Environments

`AppEnvironment` represents deployment environments and exposes conservative policies:

```swift
let environment = AppEnvironment.staging

if environment.enablesVerboseLogging {
    // Enable additional development diagnostics.
}
```

URLs, credentials, and feature flags should remain in application configuration rather than being hard-coded into BaseCore.

## Extensions

Available helpers include:

- `Collection.isNotEmpty`
- `Collection[safe:]`
- `String.trimmed()`
- `Optional.isNil` and `Optional.isNotNil`
- `Date.nowTimestamp`

Only add an extension when it is domain-independent and used by multiple modules. Feature-specific helpers belong beside their feature.

## Errors

`CoreError` contains only generic technical failures. Network, storage, domain, and UI errors must remain in their owning packages.

## Testing

Run the package tests from the `BaseCore` scheme. Tests cover logging filters and injection, lock-isolated mutation, environments, errors, and extensions.
