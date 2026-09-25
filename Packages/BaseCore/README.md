# BaseCore

BaseCore is the lowest-level package. It contains framework-independent utilities shared across modules and must not depend on Domain, networking, persistence, UI, or TCA.

## Public capabilities

- `Logger.log(_:)` prints file, line, and function information only in Debug builds.
- `CoreError` provides small cross-module error primitives.
- Date, String, and Optional extensions provide reusable helpers.

```swift
import BaseCore

Logger.log("Profile loading started")
guard let url = URL(string: rawURL) else {
    throw CoreError.invalidURL
}
```

Do not log tokens, credentials, or personal payloads. Add a helper here only when it is framework-independent and reused by multiple packages. Use structured concurrency and `MainActor.run` directly instead of adding dispatch wrappers.
