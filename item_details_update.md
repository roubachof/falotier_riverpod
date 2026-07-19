# Item details update: pessimistic toggle with animation

> Fifth in the [falotier loading states](README.md#document-in-progress) series.
>
> - Case 1: [Loading from scratch, simplest use case](load_from_scratch.md)
> - Case 2: [Loading from scratch, a sequence of dependencies](load_from_scratch_case2.md)
> - Case 3: [Refreshing](refreshing.md)
> - Case 4: [List update](list_update.md)
> - **Case 5 (this doc): Item details update** — toggle the lamp on the detail screen

## The use case

The user navigates from the list to a detail screen showing a single street lamp. They tap the lamp. The lamp turns on (or off). The animation is the whole point — a flame that grows for 20 seconds when lighting, a flame that fades out in 2 seconds when extinguishing.

The requirements:

- **Instant visual feedback.** The flame animation starts the moment the user taps, not after the server round-trip.
- **Pessimistic data.** The canonical `isLit` value only flips when the server confirms. If the call fails, the lamp stays in its previous state.
- **Cross-screen consistency.** The user came from the list. After toggling, when they go back to the list, the tile must reflect the new state. No sync code, no manual refresh.

## Why not optimistic?

The classic argument for optimistic updates is *"the user gets instant feedback"*. We have that covered differently:

- The flame animation (`FlameAction { idle, turningOn, turningOff }`) drives the visual during the async call.
- The animation overrides the canonical `widget.isLit` value while a transition is in progress — `switch (_action)` chooses which animation to play.
- After the server confirms, the canonical `isLit` flips and the animation settles into its steady state.

In other words: **the optimistic feel comes from the animation, not from flipping the data early.** We don't need to fake the data state, we just need a visual cue that something is happening.

And the cost of optimistic-with-rollback (try/catch + restore on every mutation + the visual jarring of a flip-then-unflip on failure) outweighs the benefit when the animation already provides the perceived instant response.

## The state machine

The `LitLampWidget` has a single state field: `_action`. It's a small enum:

```dart
enum FlameAction { idle, turningOn, turningOff }
```

The visual the widget renders depends on `_action` and on `widget.isLit` (which comes from the store via the parent `DetailsBody`):

```
                    widget.isLit
                         │
          ┌──────────────┴──────────────┐
          ▼                             ▼
        false                          true
          │                             │
          │ user taps                   │ user taps
          ▼                             ▼
   ┌───────────────┐             ┌───────────────┐
   │ _action =     │             │ _action =     │
   │ turningOn     │             │ turningOff    │
   │               │             │               │
   │ flame grows   │             │ flame fades   │
   │ for 20s       │             │ for 2s        │
   └───────┬───────┘             └───────┬───────┘
           │                             │
           │ await store.toggle(id)      │ await store.toggle(id)
           │                             │
           ▼                             ▼
   ┌───────────────────────────────────────────────┐
   │  on finally: _action = idle                   │
   │                                               │
   │  widget.isLit now reflects the server state   │
   │  (true on success, unchanged on failure)      │
   │                                               │
   │  steady flame (if lit) or empty box (if off)  │
   └───────────────────────────────────────────────┘
```

Three branches in the `build` method, three animations in the `_buildFlame` switch:

```dart
Widget _buildFlame() {
  final container = Container(
    height: 120,
    width: 120,
    decoration: _buildFlameDecoration(),
  );

  return switch (_action) {
    FlameAction.idle => container
        .animate(
          key: const Key('flame'),
          onPlay: (controller) => controller.loop(count: null, reverse: true),
        )
        .fade(duration: _pulseDuration, begin: 1.0, end: 0.7)
        .scale(
          duration: _pulseDuration,
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
        ),

    FlameAction.turningOn => container
        .animate(key: const Key('on'))
        .fade(duration: _turnOnFadeDuration, begin: 1.0, end: 0.2)
        .scale(
          duration: _turnOnScaleDuration,
          begin: const Offset(0.2, 0.2),
          end: const Offset(10, 10),
        ),

    FlameAction.turningOff => container
        .animate(key: const Key('off'))
        .fade(duration: _turnOffDuration, begin: 1.0, end: 0.2)
        .scale(
          duration: _turnOffDuration,
          begin: const Offset(1, 1),
          end: const Offset(0.2, 0.2),
        ),
  };
}
```

The earlier version of this widget had three boolean flags (`_isLoading`, `_isTurningOn`, `_isTurningOff`) that were mutually exclusive at runtime but nothing in the type system enforced it. Sixteen combinatory states, most of them meaningless. The enum encodes the actual machine: three valid values, the compiler enforces the switch is exhaustive.

## The tap handler

```dart
Future<void> _onTap() async {
  Feedback.forTap(context);
  await runCommand(
    context: context,
    action: () => ref.read(streetLampStoreProvider.notifier).toggle(widget.id),
    onLoadingStart: () => setState(() {
      _action =
          widget.isLit ? FlameAction.turningOff : FlameAction.turningOn;
    }),
    onLoadingEnd: () {
      if (mounted) {
        setState(() => _action = FlameAction.idle);
      }
    },
  );
}
```

Three things to notice:

1. **`Feedback.forTap(context)` first.** Haptic feedback before the async, so the user immediately knows the tap registered.
2. **`onLoadingStart` flips `_action` synchronously** — before the await. This is what triggers the flame animation immediately. We don't wait for the server to start the visual.
3. **`onLoadingEnd` is guarded by `if (mounted)`** — by the time the await completes, the user may have navigated away from the detail screen. We don't want to call `setState` on a disposed widget.

The `runCommand` helper handles the try/catch + SnackBar on error. If `store.toggle()` throws, the SnackBar shows, `_action` resets to `idle` in `onLoadingEnd`, and `widget.isLit` was never flipped (because the store is pessimistic). The visual returns to its previous stable state — no rollback code needed.

## The store mutation

The actual mutation lives on `StreetLampStore`:

```dart
Future toggle(String id) async {
  final previous = state.value!;
  final lamp = previous[id]!;
  final updated = lamp.copyWith(isLit: !lamp.isLit);

  await _repo.addOrUpdate(updated);               // pessimistic
  state = AsyncData({...previous, id: updated});  // single write, after success
}
```

Three lines worth pointing out:

1. **Capture `previous` before the await.** If the server call fails, we still have the previous state — we just don't write anything and rethrow. The catch block (in `runCommand`) shows the SnackBar.
2. **Await the server before writing state.** This is what makes it pessimistic. The canonical `isLit` value only changes after the server has confirmed.
3. **Write the new map in one assignment.** `state = AsyncData({...previous, id: updated})` produces a new `Map` with the updated lamp. Riverpod notifies dependents, every view rebuilds.

## Cross-screen consistency for free

The detail screen watches the derived `streetLampProvider(id:)`:

```dart
final lampAsyncValue = ref.watch(streetLampProvider(id: widget.id));
```

The list screen watches the derived `zoneLampsProvider(zone:)` (transitively, via `lampListProvider`).

Both derive from `streetLampStoreProvider`. When `store.toggle(id)` writes new state, **both screens rebuild**. The user sees the flame toggle on the detail screen, and when they navigate back, the list tile has already updated its visual (`isLampLit: lamp.isLit`).

No sync code. No `onToggleComplete` callback chain. No "refresh the list when returning from detail". The store is the single source of truth, the views are pure projections, Riverpod handles the rest.

This is the real win of the normalized store pattern. Before, falotier had `ZoneStreetLamps` for the list and `StreetLampState` for the detail, with manual cross-provider sync in `updateLight()`. Toggling from detail meant calling the list provider's `addOrUpdate` then updating the detail state — two writes, implicit ordering, drift if anything went wrong in between. Now there's one write, in one place, and every view stays consistent.

## To sum up

1. **Drive the optimistic feel from the animation, not from flipping data early.** The flame animation gives instant feedback; the canonical `isLit` flips only when the server confirms.
2. **A small enum beats several booleans.** `FlameAction { idle, turningOn, turningOff }` encodes the actual machine state and lets the compiler verify the switch is exhaustive.
3. **Guard `setState` after async with `if (mounted)`.** The user can navigate away while the toggle is in flight.
4. **Pessimistic = simpler code.** No try/catch in the store, no rollback, no drift. The store awaits the server, writes state in one assignment, done.
5. **Single source of truth = cross-screen consistency for free.** List and detail both derive from the store, so one write updates both. No manual sync, ever.

![update an item](docs/lamp_details_update.jpg)
