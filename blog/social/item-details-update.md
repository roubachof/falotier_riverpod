# Social posts — Item details update with Riverpod

Source: [blog/item-details-update.md](../item-details-update.md)

---

## LinkedIn

Optimistic updates are everywhere in the Flutter discourse.

The pitch is seductive: "Don't wait for the server — flip the local state immediately. The user gets instant feedback. Roll back if it fails."

So you build it. You flip `isLit` to `true` instantly. You start the server call. If it succeeds, great, nothing to do. If it fails, you flip `isLit` back to `false` and show a SnackBar.

Then you realize: the flame animation already gives the user instant feedback. The flip is invisible. You're writing rollback code for an effect the user never sees.

I just published the last post in my falotier Riverpod series — on the toggle use case. The setup:

- The user taps a lamp on the detail screen.
- A flame animation grows for 20 seconds (or fades for 2 if turning off).
- The server call is in flight during the animation.
- When the server confirms, the canonical `isLit` value flips and the animation settles.
- If the server fails, the animation completes back to idle, the data never changed, no rollback needed.

The insight: **the optimistic feel comes from the animation, not from flipping data early.** Which means we don't need optimistic state.

The state machine is a small enum: `FlameAction { idle, turningOn, turningOff }`. The previous version had three booleans (`_isLoading`, `_isTurningOn`, `_isTurningOff`) — mutually exclusive at runtime but nothing in the type system enforced it. 16 combinatory states, most of them meaningless. The enum encodes the actual machine: three valid values, the compiler verifies the switch is exhaustive.

The store mutation is three lines, pessimistic, no try/catch, no rollback:

```dart
Future toggle(String id) async {
  final previous = state.value!;
  final lamp = previous[id]!;
  final updated = lamp.copyWith(isLit: !lamp.isLit);
  await _repo.addOrUpdate(updated);
  state = AsyncData({...previous, id: updated});
}
```

And because both the detail screen and the list screen derive from the same store, when the user navigates back, the list tile has already updated. No sync code. No callback chain. No "refresh on return".

Full write-up with diagrams + code: https://sharpnado.com/item-details-update-riverpod/

#flutter #riverpod #statemanagement #mobiledevelopment #dart

---

## Reddit (r/FlutterDev)

**Title:** Optimistic updates are overrated when you have animations — here's why I moved to 100% pessimistic mutations

**Body:**

The conventional wisdom in the Flutter/Riverpod community is: "for instant UX, use optimistic updates with rollback."

I bought into this for a while. Then I realized something while refactoring falotier's lamp toggle:

The flame animation already provides instant feedback. The optimistic data flip is invisible to the user — the animation overrides the data while a transition is in progress.

So I'm writing try/catch + rollback code on every mutation, for an effect the user never sees.

I just switched to **100% pessimistic mutations** and the code is roughly half the size:

```dart
Future toggle(String id) async {
  final previous = state.value!;
  final lamp = previous[id]!;
  final updated = lamp.copyWith(isLit: !lamp.isLit);
  await _repo.addOrUpdate(updated);               // pessimistic
  state = AsyncData({...previous, id: updated});  // single write, after success
}
```

No try/catch in the store. No rollback. The store awaits the server, writes state in one assignment, done.

The instant feedback comes from a small enum-driven animation:

```dart
enum FlameAction { idle, turningOn, turningOff }
```

On tap, `_action` flips to `turningOn` (or `turningOff`) synchronously — *before* the await. The animation starts immediately. When the await completes (success or failure), `_action` resets to `idle`. On success, the canonical `widget.isLit` has flipped (because the store wrote new state). On failure, the store never wrote, the data is unchanged, the visual returns to its previous stable state — **no rollback code needed**.

Bonus: the enum replaces three booleans (`_isLoading`, `_isTurningOn`, `_isTurningOff`) that were mutually exclusive at runtime but unenforced by the type system. 16 combinatory states → 3 valid values + a compiler-checked exhaustive switch.

For `remove` operations, pessimistic + overlay spinner is also better UX than optimistic-with-rollback: the item stays visible during the call, disappears cleanly when the server confirms. No disappear-then-reappear jarring on failure.

Full write-up (the last post in my falotier Riverpod series — item details update use case):

https://sharpnado.com/item-details-update-riverpod/

Source code: https://github.com/roubachof/falotier

Genuinely curious — for those using optimistic updates, what's the use case where the animation (or overlay) doesn't already cover the perceived latency? Considering whether there are scenarios I'm not thinking of.

---

## BlueSky

Optimistic updates with rollback: try/catch on every mutation, drift on failure, jarring flip-then-unflip on error.

For 95% of cases, you don't need them. The animation already gives instant feedback.

Switched falotier to 100% pessimistic. Code is half the size.

sharpnado.com/item-details-update-riverpod/

#flutter #riverpod
