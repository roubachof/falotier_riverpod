# List updates with Riverpod: pessimistic mutations, no sync code

Adding and removing items from a list backed by a Riverpod store — without writing a single line of cross-provider sync code.

This is the Falotier's series:

1. [Falotier's introduction: description of the loading states](https://sharpnado.com/falotier-riverpod/)
2. [Architecture walkthrough](https://sharpnado.com/falotier-riverpod-part-2-architecture/)
3. [`Loading from scratch` use case study](https://sharpnado.com/loading-data-with-riverpod/)
4. `Refreshing` use case study (coming soon)
5. `List update` use case study (**you are here**)
6. `Item details update` use case study
7. Design implementation

[GitHub - roubachof/falotier: source code for this series](https://github.com/roubachof/falotier)

Adding and removing items from a list sounds like the easiest thing in an app.

Then you start writing it.

You need a modal for the add flow.\
The modal shows items the user doesn't already have.\
When the user picks one, you call the server.\
While the call is in flight, you want an overlay so they can't tap twice.\
On success, you close the modal and the new item appears in the list — at the right sorted position.\
On error, you show a SnackBar, the modal stays open, the list is unchanged.

For the remove flow, you want a small icon on each tile that turns into a spinner during the call.\
On success, the item disappears with a smooth exit animation.\
On error, the icon goes back to normal and a SnackBar explains.

And **the list and the modal need to stay consistent**.\
The street the user just added to the lamps must disappear from the available-streets list.\
Without writing sync code in three places.

Right.\
Let's see how Riverpod gets us there.

## The shape of the problem

Two flows, three moving parts each.

### Add flow

```
   User taps "Add street" FAB
              │
              ▼
   ┌────────────────────────────────────┐
   │  Modal bottom sheet                │
   │  AvailableStreetsProvider          │  ← derived from store + streets
   │  (streets without lamps)           │
   └────────────────┬───────────────────┘
                    │ tap a street
                    ▼
   ┌────────────────────────────────────┐
   │  store.addOrUpdate(lamp)           │  ← async, pessimistic
   │  Overlay: "Street is being added"  │
   └────────────────┬───────────────────┘
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
     success                  error
        │                       │
        ▼                       ▼
   ┌──────────────────┐    ┌──────────────────┐
   │  Navigator.pop() │    │  SnackBar        │
   │  modal closes    │    │  modal stays     │
   │  store emits     │    │  overlay hides   │
   │  new state       │    │  list unchanged  │
   └──────────────────┘    └──────────────────┘
```

### Remove flow

```
   User taps the cross on a list tile
              │
              ▼
   ┌────────────────────────────────────┐
   │  IconButtonCommand                 │
   │  cross icon → AppLoadingWidget     │  ← local widget state
   │  runCommand(                       │
   │    action: store.remove(lamp.id),  │  ← async, pessimistic
   │  )                                 │
   └────────────────┬───────────────────┘
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
     success                  error
        │                       │
        ▼                       ▼
   ┌──────────────────┐    ┌──────────────────┐
   │  store emits     │    │  SnackBar        │
   │  new state       │    │  tile stays      │
   │  tile removed    │    │  icon restored   │
   │  DiffUtil exit   │    │  list unchanged  │
   │  animation       │    │                  │
   └──────────────────┘    └──────────────────┘
```

Both flows are **pessimistic**: we await server confirmation before updating local state.\
Animations and overlays cover the perceived latency. There's no optimistic guess, no rollback.

## The add flow, in code

The add modal is `StreetList` in `lib/presentation/add_street/street_list.dart`:

```dart
class StreetList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedZone = ref.watch(selectedZoneProvider);
    final streetListAsyncValue =
        ref.watch(availableStreetsProvider(zone: selectedZone.value!));

    return LoaderOverlay(
      overlayWidgetBuilder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLoadingWidget(),
            AppGap.regular(),
            AppText.paragraphMedium('Street is being added'),
          ],
        ),
      ),
      child: AsyncValueWidget<IList<Street>>(
        streetListAsyncValue,
        onErrorButtonTap: () => ref
            .read(availableStreetsProvider(zone: selectedZone.value!).notifier)
            .reload(),
        childBuilder: (data) => ListView.separated(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            final street = data[index];
            return InkWell(
              key: Key(street.id),
              onTap: () => _addStreet(context, street, ref),
              child: /* street name + district */,
            );
          },
        ),
      ),
    );
  }

  _addStreet(BuildContext context, Street data, WidgetRef ref) {
    final store = ref.read(streetLampStoreProvider.notifier);
    final streetLamp = StreetLamp.fromStreet(data);
    handleAsyncCommand(
      context: context,
      future: () => store.addOrUpdate(streetLamp),
      onSuccess: () {
        if (context.mounted) Navigator.pop(context);
      },
      showOverlay: true,
    );
  }
}
```

Key bits:

- **`LoaderOverlay`** wraps the whole modal. When `handleAsyncCommand` is called with `showOverlay: true`, the overlay appears with a spinner and the message *"Street is being added"*. The user can't tap another street while the call is in flight — the modal is visually frozen but still visible.
- **`handleAsyncCommand`** wraps the async call in a try/catch. On error, it shows a SnackBar; on success, it runs the `onSuccess` callback (closing the modal).
- **`store.addOrUpdate(lamp)`** is pessimistic. It awaits the server, gets back the saved lamp with a real id, then writes to the store state in one assignment. The list rebuilds with the new item.
- **`if (context.mounted) Navigator.pop(context)`** — the user could swipe the modal away mid-call. We check `context.mounted` before popping to avoid a `deactivated widget's ancestor is unsafe` crash. (Yes, this is a real bug we hit. Yes, the fix is one `if`.)

### The cross-view magic

The store is the **single source of truth**.\
When `store.addOrUpdate()` writes to the state, every derived view (the lamp list on the home screen, the available streets in the modal) rebuilds automatically.\
So when the user closes the modal:

- The lamp list already has the new item at the right sorted position.
- The available streets modal no longer shows the just-added street (because it's now a lamp).

No sync code. No "refresh the list after add". The store changed, the views follow.

This is the whole point of the normalized store pattern.\
In earlier versions of falotier, I had a `ZoneStreetLamps` provider for the list and a separate `StreetLampState` provider for the detail, with manual sync between them.\
Adding a lamp meant calling the list provider's `addOrUpdate` and then updating the detail state — two writes, implicit ordering, drift if anything failed in between.\
Now there's one write, in one place, and every view stays consistent.

## The remove flow, in code

`IconButtonCommand` is a small reusable widget that turns any icon into an async-action trigger with local loading state:

```dart
class IconButtonCommand extends StatefulWidget {
  const IconButtonCommand({
    super.key,
    required this.iconData,
    required this.onPressed,
  });

  final IconData iconData;
  final Future Function() onPressed;

  @override
  State<IconButtonCommand> createState() => _IconButtonCommandState();
}

class _IconButtonCommandState extends State<IconButtonCommand> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (_isLoading) {
      return AppPadding(
        padding: const AppEdgeInsets.regular(),
        child: SizedBox(
          height: theme.icons.sizes.regular,
          width: theme.icons.sizes.regular,
          child: const AppLoadingWidget(),
        ),
      );
    }

    return IconButton(
      color: theme.colors.foreground,
      icon: AppIcon.regular(widget.iconData),
      onPressed: () => _internalOnPressed(context),
    );
  }

  Future _internalOnPressed(BuildContext context) {
    return runCommand(
      context: context,
      action: widget.onPressed,
      onLoadingStart: () => setState(() => _isLoading = true),
      onLoadingEnd: () => setState(() => _isLoading = false),
    );
  }
}
```

Notes:

- **Local widget state for the spinner.** `_isLoading` lives in the `StatefulWidget`. That's a widget-local UI concern — exactly what Riverpod's [DO/DON'T](https://riverpod.dev/docs/root/do_dont) says is fine.
- **`runCommand`** handles the try/catch + SnackBar on error. We don't reimplement it per call site.
- **The action itself is passed in.** The widget is reusable — it doesn't know whether it's removing a lamp, logging out, or anything else.

The actual remove wiring lives in the home list tile:

```dart
onRemove: () =>
    ref.read(streetLampStoreProvider.notifier).remove(lamp.id),
```

That's it. The tile passes its `lamp.id` to the store.\
The store awaits the server, then writes new state.\
The list rebuilds with one less item.

## Smooth list animations with `DiffUtilSliverList`

When the store emits new state without an item, the list rebuilds.\
We use `DiffUtilSliverList` to compute the diff between the previous and new list, and animate insertions and removals:

```dart
DiffUtilSliverList.fromKeyedWidgetList(
  children: data.map((lamp) {
    return AppPadding(
      key: Key(lamp.id),   // ← keyed by lamp id, so diff is reliable
      // ... tile ...
    );
  }).toList(),
  insertAnimationBuilder: (context, animation, child) =>
      FadeTransition(opacity: animation, child: child),
  removeAnimationBuilder: (context, animation, child) => FadeTransition(
    opacity: animation,
    child: SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0,
      child: child,
    ),
  ),
);
```

The keys are lamp ids, so the diff is reliable across reorderings.\
When `store.remove(id)` drops an item, DiffUtil spots it and plays the exit animation (fade + size collapse).\
When `store.addOrUpdate()` adds an item, DiffUtil plays the insert animation (fade in).

We never animate this ourselves. We just update the data, the diff library does the rest.\
This is the kind of thing that's easy to over-engineer.\
You could write custom transitions for each removal, manually track which widget is leaving, schedule an animation, then remove the data when the animation completes.\
**Don't.** Just give the diff library keyed children and let it work.

## To sum-up

1. Pessimistic mutations, always. The store awaits the server, then writes new state in a single assignment. No optimistic guess, no rollback.
2. Local widget state for the UI feedback. `IconButtonCommand` has `_isLoading`. The add modal has its `LoaderOverlay`. These are widget-local concerns, not provider state.
3. The store is the single source of truth. Add or remove in one place, every derived view follows.

The end result: a list that updates smoothly from anywhere in the app, with overlays and spinners where they should be, SnackBars when things go wrong, and zero cross-provider sync code.

![add item](https://sharpnado.com/content/images/2024/09/add_item.jpg)

Don't resist: embrace it :)
