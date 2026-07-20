# Social posts — List updates with Riverpod

Source: [blog/list-update.md](../list-update.md)

---

## LinkedIn

Adding and removing items from a list sounds easy.

Then you start writing it.

You need a modal for the add flow. The modal shows items the user doesn't already have. When the user picks one, you call the server. While the call is in flight, you want an overlay so they can't tap twice. On success, you close the modal and the new item appears at the right sorted position. On error, you show a SnackBar, the modal stays open, the list is unchanged.

For the remove flow, you want a small icon on each tile that turns into a spinner during the call. On success, the item disappears with a smooth exit animation. On error, the icon goes back to normal.

And — the part that always gets messy — the list and the modal need to stay consistent. The street the user just added must disappear from the available-streets list. Without writing sync code in three places.

For years my answer was manual cross-provider sync. Add the lamp to the list provider, then update the detail provider, then update the available-streets provider. Three writes, implicit ordering, drift if anything failed in between.

My current answer is a normalized store. One provider holds the canonical state indexed by id (`Map<String, StreetLamp>`). Every view (list, detail, available streets) is a pure derived projection. One write to the store, every view rebuilds consistently. Zero sync code.

The mutations are all pessimistic. We await server confirmation before updating local state. The animations and overlays cover the perceived latency — there's no optimistic guess, no rollback.

I just published a write-up of how falotier does add + remove with this pattern, including the reusable `IconButtonCommand` widget (turn any icon into an async-action trigger with local spinner state) and the DiffUtilSliverList setup for smooth insert/remove animations.

Code + diagrams: https://sharpnado.com/list-update-riverpod/

#flutter #riverpod #statemanagement #mobiledevelopment #dart

---

## Reddit (r/FlutterDev)

**Title:** Add/remove items from a Riverpod-driven list with zero cross-provider sync code — here's the normalized store pattern I use

**Body:**

Every Flutter dev eventually hits this: a list screen, an add-modal, a remove button on each tile, and the requirement that everything stays consistent.

The classic approach is to have a provider per view (`ZoneStreetLampsProvider`, `StreetLampStateProvider`, `AvailableStreetsProvider`) and manually sync them on every mutation. Three writes, implicit ordering, drift if anything fails.

I've moved to the normalized store pattern instead (Redux EntityAdapter / NgRx Entity style) and it removes a whole class of bugs.

```dart
@Riverpod(keepAlive: true)
class StreetLampStore extends _$StreetLampStore {
  @override
  Future<Map<String, StreetLamp>> build() async {
    final zone = await ref.watch(selectedZoneProvider.future);
    final lamps = await _repo.getList(zone);
    return {for (final l in lamps) l.id: l};
  }

  Future addOrUpdate(StreetLamp lamp) async {
    final saved = await _repo.addOrUpdate(lamp);     // pessimistic
    state = AsyncData({...state.value!, saved.id: saved});
  }

  Future remove(String id) async {
    final lamp = state.value![id]!;
    await _repo.remove(lamp);                          // pessimistic
    state = AsyncData({...state.value!}..remove(id));
  }
}
```

The list and detail screens don't hold entity state themselves. They're pure derived views over the store:

```dart
@riverpod
Future<IList<StreetLamp>> zoneLamps(ref, {required zone}) async {
  final store = await ref.watch(streetLampStoreProvider.future);
  return store.values.where((l) => l.street.zone == zone).toIList();
}
```

One mutation → every view stays consistent. No manual sync, no drift.

Combined with:
- `IconButtonCommand` — a small reusable StatefulWidget for icon → spinner during async actions (local `_isLoading`, not a provider)
- `DiffUtilSliverList` for insert/remove animations keyed by lamp id
- `runCommand` helper for centralized try/catch + SnackBar on error
- 100% pessimistic mutations (animations + overlays cover perceived latency)

Full write-up (it's the latest in my falotier Riverpod series):

https://sharpnado.com/list-update-riverpod/

Source code: https://github.com/roubachof/falotier

How do you handle this in your apps? Still doing manual sync, or have you moved to a normalized store?

---

## BlueSky

Adding items to a Riverpod list?

Used to be: 3 providers (list / detail / available), manual cross-provider sync, drift on failure.

Now: one normalized store (Map<id, StreetLamp>), every view derived, zero sync code.

New post on the list-update use case in falotier:

sharpnado.com/list-update-riverpod/

#flutter #riverpod
