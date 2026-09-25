# FeatureHome and PostDetailFeature

FeatureHome manages post loading, refresh, retry, stable UI failures, and navigation to post details. It follows TCA: State is the source of truth, Actions describe events, the Reducer owns state transitions, and Effects perform I/O.

## State

- `posts`: successfully loaded domain entities.
- `isLoading`: whether a request is active.
- `failure`: connection, invalid-data, or unavailable failure.
- `path`: `StackState<HomeDestination.State>` for testable navigation.

```text
.task / .refresh / .retryTapped
    -> isLoading = true, failure = nil
    -> postsClient.fetchPosts()
    -> .postsResponse(TaskResult)
       success: update posts and finish loading
       failure: map Error to LoadFailure
```

Loading uses a stable cancellation identifier. A new load cancels the previous one, and `.cancelLoading` explicitly stops it.

Tapping a post appends `PostDetailFeature.State` to the navigation path. Keep navigation in feature state instead of local view flags.

Tests should cover successful loading, failure classification, refresh, retry, cancellation, push navigation, and path removal.
