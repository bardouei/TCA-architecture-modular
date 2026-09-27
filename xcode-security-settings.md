# Xcode Security Decisions

Updated: 2026-09-27

## Application targets

The `TCAtest` and `MyAppClip` targets enable:

- Enhanced Security
- Pointer authentication
- Hardware-checked pointer arithmetic slice
- Product validation

`MyAppClip` now uses Swift 6 with complete strict-concurrency checking, matching the main application.

## Runtime and data protections

- Network logs redact authorization, cookie, and API-key headers.
- Request and response payload contents are never written to unified logging.
- Authentication refresh is injected; the previous generated-token placeholder is removed.
- Keychain writes use update-or-add so a failed replacement cannot destroy the previous value.
- Download transfer sessions invalidate on success, error, and cancellation.
- Multipart values reject CR/LF and quote injection and enforce a 20 MiB in-memory limit.
- Showcase operations are cancelled when superseded or when the view disappears.

## CI policy

- Every Swift package runs its own tests.
- Main application and App Clip are built with warnings treated as errors.
- Main and App Clip unit targets run separately from UI tests.
- Static analysis runs on each push and pull request.
- Address Sanitizer and Thread Sanitizer run weekly.

## Deferred

- Hardware-memory-tagging entitlements are not added because their device/platform availability
  must be verified against the signing profile used for release.
- Certificate pinning is intentionally not enabled for public sample APIs. Production endpoints
  should evaluate pinning and a rotation strategy separately.
