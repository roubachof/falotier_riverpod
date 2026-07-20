# Social posts — Refreshing with Riverpod

Source: [blog/refreshing.md](../refreshing.md)

---

## LinkedIn

You're looking at a list. Everything's fine.

You pull down to refresh.

The list disappears, replaced by a full-page spinner.

Three seconds pass.

The list comes back.

Why did the list go away? You *had* it. The server was just slow.

This is one of those UX papercuts that look like nothing in a screenshot and feel awful in your hand. I just wrote up how Riverpod fixes it — and the fix is small, but only once you understand what an `AsyncValue` really is.

Most developers learn three states: loading, data, error. The grown-up version has four. The crucial one is *refreshing*: `isLoading == true` (a new fetch is in progress) BUT `hasValue == true` (the previous data is still there).

If you don't check `hasValue` during a refresh, you blank the screen with a spinner — taking away data the user already had. If you do check it, you keep the old list visible while the new one loads, and on error you surface a SnackBar instead of a full-page error wall.

The implementation is one small helper: `_tryReturningData`. If the AsyncValue still has a previous value, render it. Otherwise, render the loading or error widget.

Two layers, two responsibilities:
- The widget layer keeps the old data visible.
- The command layer reports errors as a non-blocking SnackBar.

Full write-up (with the state-transition diagram and the actual `RefreshIndicator` call site): https://sharpnado.com/refreshing-riverpod/

It's the latest in my falotier series — a state-management PoC for real-life Flutter apps.

#flutter #riverpod #ux #mobiledevelopment #dart

---

## Reddit (r/FlutterDev)

**Title:** The pull-to-refresh UX papercut: are you blanking the screen when the user already had data?

**Body:**

A surprisingly common UX bug in Flutter apps:

1. User has a list on screen
2. User pull-to-refreshes
3. List disappears, full-page spinner takes over
4. Server takes 2 seconds
5. List comes back

The user had data. You took it away. Why?

The root cause is usually a misunderstanding of `AsyncValue`. People learn three states: loading / data / error. But Riverpod's `AsyncValue` has four — the crucial one being **refreshing**:

- `isLoading = true`
- `isRefreshing = true`
- `hasValue = true` ← the previous data is still available

If your widget's `when()` handler renders a full-page loading widget whenever `isLoading == true`, you'll blank the screen on every refresh — even though the old data is right there in `asyncValue.value`.

The fix in my apps is one small helper:

```dart
Widget _tryReturningData(String stateName, Widget orElse) {
  if (asyncValue.hasValue) {
    return _handleSuccess(asyncValue.value as T);
  }
  return orElse;
}
```

Call it from both `_handleLoading` and `_handleError`. If the AsyncValue still has a previous value, render that instead of the loading/error UI.

For refresh errors specifically, the widget keeps showing the old data while a SnackBar surfaces the failure non-blockingly. Two layers, two responsibilities:

- Widget layer: keep old data visible
- Command layer: report errors as SnackBars

Full write-up with state-transition diagram and the `RefreshIndicator` call site: https://sharpnado.com/refreshing-riverpod/

Source: https://github.com/roubachof/falotier

---

## BlueSky

You're looking at a list. You pull to refresh. The list disappears. Spinner. Three seconds. List comes back.

Why did the list go away? You had it.

The pull-to-refresh papercut — and how Riverpod's AsyncValue fixes it (hint: hasValue during refresh):

sharpnado.com/refreshing-riverpod/

#flutter #riverpod
