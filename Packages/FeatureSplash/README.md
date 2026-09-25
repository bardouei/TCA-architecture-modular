# FeatureSplash

FeatureSplash is a small TCA feature that displays the launch state and reports completion to its parent. It uses an injected `ContinuousClock`, making its delay deterministic in tests.

```text
View appears -> .onAppear -> sleep(2 seconds) -> .finished
View leaves  -> .onDisappear -> cancel(timer)
AppFeature receives .finished -> destination becomes Home
```

The timer effect has a stable cancellation identifier and uses `cancelInFlight`, so repeated appearances do not create parallel timers. Test it with a `TestClock` and virtual time rather than waiting for two real seconds.
