# App Clip

The App Clip is a lightweight flow for loading and displaying one post from an invocation URL. Its TCA feature is independent from AppFeature to keep the binary and dependency graph focused.

## Input and actions

- `.task`: loads the initial post.
- `.invocationURLReceived(URL)`: parses a post identifier from the query or path and starts a new request.
- `.retryTapped`: retries the current request.
- `.cancelLoading`: cancels the active effect.

Supported URL shapes:

```text
https://example.com/clip?postId=12
https://example.com/posts/12
```

The view forwards both `onOpenURL` and browsing `NSUserActivity` URLs to the reducer. Invalid or non-positive identifiers are rejected without force-unwrapping.

The store has stable identity in `AppClipApp`. Network loading is skipped when the process is an XCTest host, so unit tests never wait for live internet access.

Tests cover query/path parsing, successful loading, failure classification, retry, and cancellation using an injected post client.
