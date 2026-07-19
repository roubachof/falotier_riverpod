# Refreshing with Riverpod: keeping the old data while fetching new

> Third in the [falotier loading states](README.md#document-in-progress) series.
>
> - [Case 1: Loading from scratch, simplest use case](load_from_scratch.md)
> - [Case 2: Loading from scratch, a sequence of dependencies](load_from_scratch_case2.md)
> - **Case 3 (this doc): Refreshing already-loaded data**

## The use case

You have a list on screen. The user pulls to refresh. What should happen?

- The existing list stays visible. **You don't blank the screen with a full-page spinner** — the user just had data, you don't take it away from them.
- A small refresh indicator appears (the `RefreshIndicator` spinner).
- If the refresh succeeds, the list updates silently. Maybe nothing visibly changes (if data is identical), maybe a few items appear/disappear with animations.
- If the refresh fails, **the existing list stays untouched** and a `SnackBar` explains the failure. The user can keep using the app with the data they had.

This is materially different from the cold-start loading case, where there's no previous data to display and a full-page loading widget is the right answer.

## The three AsyncValue states at play

A Riverpod `AsyncValue<T>` has more nuance than just `loading` / `data` / `error`. There are four states worth knowing:

| State | `isLoading` | `isRefreshing` | `hasValue` | What it means |
|---|---|---|---|---|
| Initial loading | `true` | `false` | `false` | Cold start, no data yet |
| Refreshing | `true` | `true` | `true` | Re-fetching, previous data still available |
| Data | `false` | `false` | `true` | Stable, current data |
| Error (with previous) | `false` | `false` | `true` | Latest fetch failed, but we still have old data |

The crucial one is **refreshing**: `isLoading == true` (because the new fetch is in progress) **but `hasValue == true`** (because we kept the previous value). When you `ref.refresh(someAsyncProvider)`, this is the state the provider goes through until the new fetch resolves.

The mistake to avoid: blindly showing the full-page `loading` widget when the `AsyncValue` is in `refreshing` state. The user had data on screen, you take it away, you show a spinner, then you bring data back. That's the UX of a slow app. Instead: keep showing the old data while the refresh runs.

## The state transition

```
                          User has the list on screen
                                     │
                                     │ pull-to-refresh
                                     ▼
                ┌─────────────────────────────────────┐
                │  AsyncValue<IList<StreetLamp>>      │
                │  state = refreshing                 │
                │  isLoading = true                   │
                │  hasValue = true  ← still the old   │
                └────────────────┬────────────────────┘
                                 │
                  ┌──────────────┴──────────────┐
                  ▼                             ▼
              success                       error
                  │                             │
                  ▼                             ▼
   ┌──────────────────────────┐    ┌──────────────────────────┐
   │  state = data            │    │  state = error           │
   │  new list shown          │    │  (with previous value)   │
   │  list diff-animates      │    │  old list stays visible  │
   │  (insert/remove)         │    │  SnackBar shows error    │
   └──────────────────────────┘    └──────────────────────────┘
```

Notice the two failure-mode differences from cold-start:

- **Cold-start error** → render the error widget + retry button (no previous data to show).
- **Refresh error** → keep rendering the previous data, just surface a SnackBar.

## Implementation: `AsyncValueWidget` handles it for us

The `AsyncValueWidget` we built in [Case 1](load_from_scratch.md) already handles refresh correctly thanks to a small `_tryReturningData` fallback:

```dart
class AsyncValueWidget<T> extends StatelessWidget {
  // ...

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      skipError: true,
      skipLoadingOnRefresh: false,
      data: _handleSuccess,
      error: _handleError,
      loading: _handleLoading,
    );
  }

  Widget _handleLoading() {
    final loadingWidget = SizedBox(
      height: containerHeight,
      child: Center(
        child: AppLoadingWidget(loadingMessage: loadingMessage),
      ),
    );

    return _tryReturningData('loading', loadingWidget);
  }

  Widget _handleError(Object error, StackTrace trace) {
    // ...
    if (asyncValue.hasValue) {
      // A SnackBar should have been displayed here
      // It should be handled by one of the handleCommand methods
      return _tryReturningData('error', errorWidget);
    }
    return errorWidget;
  }

  /// When refreshing (or refreshing-error), keep the previous data on screen
  /// instead of replacing it with a loading/error widget.
  Widget _tryReturningData(String stateName, Widget orElse) {
    if (asyncValue.hasValue) {
      _log.i('$stateName state but has a value: building success instead');
      return _handleSuccess(asyncValue.value as T);
    }
    return orElse;
  }
}
```

The pattern is the same in both `_handleLoading` and `_handleError`: **if the AsyncValue still has a previous value, render it instead of the loading/error UI.**

For loading, this is the refresh case (we're fetching, but we still have the old list). For error, this is the refresh-failure case (the new fetch threw, but the old list is still valid until proven otherwise).

The comment in `_handleError` is important: when the refresh fails, the SnackBar doesn't come from the `AsyncValueWidget`. It comes from `handleAsyncCommand` / `runCommand` at the **call site** (the place that triggered the refresh). The widget just keeps showing data. More on that below.

## The call site: `RefreshIndicator` + `LampList.refresh()`

The actual pull-to-refresh lives in `street_lamps_screen.dart`:

```dart
RefreshIndicator(
  color: theme.colors.accent,
  notificationPredicate: (_) => !ref.watch(lampListProvider).isLoading,
  onRefresh: () => handleAsyncCommand(
    context: context,
    future: () => ref.read(lampListProvider.notifier).refresh(),
  ),
  child: CustomScrollView(
    slivers: [ /* ... */ ],
  ),
),
```

Three things worth noticing.

### 1. The `notificationPredicate`

```dart
notificationPredicate: (_) => !ref.watch(lampListProvider).isLoading,
```

This disables the pull-to-refresh gesture while a load is already in progress. Without it, the user could trigger 5 concurrent refreshes by repeatedly swiping down, which would just hammer the server for no benefit. We watch the `lampListProvider`'s loading state and veto the gesture whenever it's already loading.

### 2. The `onRefresh` callback uses `handleAsyncCommand`

```dart
onRefresh: () => handleAsyncCommand(
  context: context,
  future: () => ref.read(lampListProvider.notifier).refresh(),
),
```

`handleAsyncCommand` is a thin wrapper over `runCommand` (see [Centralized command error handling](README.md)). Its job: wrap the async call in a try/catch, and on error, call `handleCommandError` which shows a `SnackBar`.

This is where the SnackBar comes from on refresh failure. The widget keeps showing the old data (thanks to `_tryReturningData`), and **the call site surfaces the error** through the SnackBar. The two layers cooperate:

- **Widget layer**: keep the old data visible, never blank the screen.
- **Command layer**: report errors as a non-blocking SnackBar.

### 3. `LampList.refresh()` invalidates the store, not itself

```dart
Future<void> refresh() {
  return ref.refresh(streetLampStoreProvider.future);
}
```

We don't invalidate `lampListProvider` itself — we invalidate `streetLampStoreProvider`, the canonical source of lamp data. The store re-fetches from the repository, emits new state, and every derived view (including `lampListProvider` via `zoneLamps`) re-renders.

This is the normalized-store advantage: one refresh, every dependent view stays consistent. There's no risk of refreshing the list but forgetting to refresh the detail screen, because they all read from the same store.

## To sum up

1. **Don't blank the screen on refresh.** Use Riverpod's `AsyncValue` nuance — a refresh keeps the previous value available via `hasValue`. Render that.
2. **Handle errors as SnackBars, not full-page error widgets.** The previous data is still valid; show it. Surface the failure non-blockingly.
3. **Disable the pull-to-refresh gesture while a load is in progress.** `notificationPredicate` is your friend.
4. **Refresh the source, not the views.** With the normalized store, invalidating the store triggers every dependent view to update consistently.

![refreshing home](docs/refresh_home.jpg)
