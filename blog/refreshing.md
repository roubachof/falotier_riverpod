---
title: Refreshing with Riverpod, or how not to blank your user's screen
feature_image: ../../docs/refresh_home.jpg
description: Pull-to-refresh sounds trivial. The UX details are not. Here is how Riverpod's AsyncValue lets you keep the old data visible while fetching new — and surface errors as SnackBars instead of full-page walls.
tags:
  - flutter
  - riverpod
  - state-management
  - ux
author: Piskariov
published_at: 2026-07-19
---

You're looking at a list. Everything's fine. You pull down to refresh. The list disappears, replaced by a full-page spinner. Three seconds pass. The list comes back.

Why did the list go away? You *had* it. The server was just slow.

This is one of those UX papercuts that look like nothing in a screenshot and feel awful in your hand. Today we fix it. With Riverpod, the fix is small and beautiful — but only once you understand what an `AsyncValue` actually is.

This post is the third in the [falotier series](https://www.sharpnado.com/falotier-riverpod). [Part 1](https://www.sharpnado.com/falotier-riverpod) and [part 2](https://www.sharpnado.com/falotier-riverpod) covered the cold-start loading cases. This one covers the *refresh* case — when the user already has data on screen and you're fetching new data in the background.

---

## The four states of an `AsyncValue`

People learn three states: `loading`, `data`, `error`. That's the grade-school version.

The grown-up version has four:

| State | `isLoading` | `isRefreshing` | `hasValue` | What it means |
|---|---|---|---|---|
| Initial loading | `true` | `false` | `false` | Cold start, no data yet |
| Refreshing | `true` | `true` | `true` | Re-fetching, **previous data still available** |
| Data | `false` | `false` | `true` | Stable, current data |
| Error (with previous) | `false` | `false` | `true` | Latest fetch failed, but we still have old data |

The crucial one is *refreshing*: `isLoading == true` (the new fetch is in progress) **but `hasValue == true`** (we kept the previous value). When you `ref.refresh(someAsyncProvider)`, this is the state it goes through until the new fetch resolves.

The mistake that causes the blank screen: blindly rendering a full-page loading widget whenever the `AsyncValue` is in a loading state. You don't look at `hasValue`. You don't realize that during refresh, there's still old data you could be showing. So you blank the screen, spin, restore. The user wonders why their list vanished.

The fix: **when the AsyncValue is loading or error but still has a previous value, render the previous value.**

---

## The state transition

Here's what should happen when the user pull-to-refreshes:

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

The error strategy is different because the *stakes* are different. In cold-start, the user has nothing — they need a way out. In refresh, the user has working data — they need to know the refresh failed, but they can keep using the app.

---

## The `AsyncValueWidget` that does it for us

In [part 1](https://www.sharpnado.com/falotier-riverpod) we built a small `AsyncValueWidget` that wraps `AsyncValue.when()` with our app's loading and error widgets. To make it refresh-aware, we add one helper:

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

  /// When refreshing (or refresh-error), keep the previous data on screen
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

The pattern is the same in both `_handleLoading` and `_handleError`: **if the AsyncValue still has a previous value, render that instead of the loading/error UI.**

For loading, this is the refresh case (we're fetching, but we still have the old list). For error, this is the refresh-failure case (the new fetch threw, but the old list is still valid until proven otherwise).

The comment in `_handleError` matters: the SnackBar doesn't come from the `AsyncValueWidget`. It comes from `runCommand` at the **call site** (the place that triggered the refresh). The widget just keeps showing data. The two layers cooperate:

- **Widget layer**: keep the old data visible, never blank the screen.
- **Command layer**: report errors as a non-blocking SnackBar.

---

## The call site

The pull-to-refresh lives in `street_lamps_screen.dart`:

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

### 1. The `notificationPredicate` disables refresh during load

```dart
notificationPredicate: (_) => !ref.watch(lampListProvider).isLoading,
```

Without it, the user could trigger 5 concurrent refreshes by repeatedly swiping down. The server gets hammered, the user gets nothing useful. We watch the loading state and veto the gesture whenever something is already in flight.

### 2. `onRefresh` uses `handleAsyncCommand`

```dart
onRefresh: () => handleAsyncCommand(
  context: context,
  future: () => ref.read(lampListProvider.notifier).refresh(),
),
```

`handleAsyncCommand` is a thin wrapper over `runCommand` (covered in [the architecture post](https://www.sharpnado.com/falotier-riverpod)). Its job: wrap the async call in a try/catch, and on error, show a SnackBar.

This is where the SnackBar comes from on refresh failure. The widget keeps showing the old data (thanks to `_tryReturningData`), and **the call site surfaces the error** as a SnackBar. Two layers, two responsibilities, no overlap.

### 3. `refresh()` invalidates the store, not itself

```dart
Future<void> refresh() {
  return ref.refresh(streetLampStoreProvider.future);
}
```

We don't invalidate `lampListProvider` directly — we invalidate `streetLampStoreProvider`, the canonical source. The store re-fetches, every derived view (list, detail, available streets) re-renders consistently.

This is the normalized-store advantage from the [architecture post](https://www.sharpnado.com/falotier-riverpod): one refresh, every dependent view stays in sync. There's no risk of refreshing the list but forgetting to refresh the detail screen, because they all read from the same store.

---

## The takeaway

Three small rules I follow for every refresh scenario:

1. **Don't blank the screen on refresh.** `AsyncValue` keeps the previous value available via `hasValue`. Render that.
2. **Surface errors as SnackBars, not full-page error widgets.** The previous data is still valid; show it. Surface the failure non-blockingly.
3. **Disable the pull-to-refresh gesture while a load is in progress.** `notificationPredicate` is your friend.

The pattern is small, but the UX win is real. The user pulls to refresh, the existing list stays visible, the small RefreshIndicator spinner confirms something is happening, the new list silently replaces the old one. On failure, the list is still there, a SnackBar explains what went wrong. Nobody's data vanishes.

This is what state management libraries are supposed to make easy. Riverpod does.

![refreshing home](../docs/refresh_home.jpg)

---

## What's next

Next post covers **list updates**: how to add and remove items from a Riverpod-driven list, with pessimistic mutations, a reusable async-command button, and DiffUtil-powered list animations. [Subscribe](https://www.sharpnado.com/#/portal/signup) to know when it drops.

Code for this series lives in [the falotier repo](https://github.com/sharpnado/falotier). The architecture decisions are documented in `proposed_improvements/` — there's a `validated/` and `implemented/` subfolder tracking the lifecycle of each refactoring.

Don't resist Riverpod: embrace it. 🙂
