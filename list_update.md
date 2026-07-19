# List update: adding and removing items from a Riverpod-driven list

> Fourth in the [falotier loading states](README.md#document-in-progress) series.
>
> - Case 1: [Loading from scratch, simplest use case](load_from_scratch.md)
> - Case 2: [Loading from scratch, a sequence of dependencies](load_from_scratch_case2.md)
> - Case 3: [Refreshing](refreshing.md)
> - **Case 4 (this doc): List update** — adding and removing items

## The use case

Your user is looking at a list. They want to change its contents:

- **Add** an item — open a modal, pick from a fixed set, send to the server, close the modal, the new item appears in the list.
- **Remove** an item — tap a small icon on a list tile, send to the server, the item disappears with a smooth exit animation.

In falotier:

- The add flow opens a modal showing the streets the user **doesn't** already have (`AvailableStreetsProvider` — a derived view that diffs the available streets against the lamps in the store).
- The remove flow has a cross icon on each tile, served by an `IconButtonCommand` widget that turns into a spinner during the async call.

Both flows are **pessimistic**: we await server confirmation before updating the local state. The animations and overlays cover the perceived latency.

## The add flow

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

### The code

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
          // ... itemBuilder rendering each street as tappable ...
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
- **`store.addOrUpdate(lamp)`** is pessimistic. It awaits the server response, gets back the saved lamp with a real id, then writes to the store state in one go. The list rebuilds with the new item.
- **`if (context.mounted) Navigator.pop(context)`** — the user could swipe the modal away mid-call. We check `context.mounted` before popping to avoid a `deactivated widget's ancestor is unsafe` crash.

### What happens on the list screen while we're in the modal

The store is the **single source of truth**. When `store.addOrUpdate()` writes to the state, every derived view (the lamp list on the home screen, the available streets in the modal) rebuilds automatically. So when the user closes the modal:

- The lamp list already has the new item at the right sorted position.
- The available streets modal no longer shows the just-added street (because it's now a lamp).

No sync code. No "refresh the list after add". The store changed, the views follow.

## The remove flow

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

### The code

`IconButtonCommand` is the small reusable widget that turns any icon into an async-action trigger with local loading state:

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

That's it. The tile passes its `lamp.id` to the store. The store awaits the server, then writes new state. The list rebuilds with one less item.

### Smooth exit animations with `DiffUtilSliverList`

When the store emits new state without an item, the list rebuilds. We use `DiffUtilSliverList` to compute the diff between the previous and new list, and animate insertions and removals:

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

The keys are lamp ids, so the diff is reliable across reorderings. When `store.remove(id)` drops an item, the DiffUtil spots it and plays the exit animation (fade + size collapse). When `store.addOrUpdate()` adds an item, the DiffUtil plays the insert animation (fade in).

We never animate this ourselves. We just update the data, the diff library does the rest.

## To sum up

1. **Pessimistic mutations, always.** The store awaits the server, then writes new state in a single assignment. No optimistic guess, no rollback.
2. **Local widget state for the UI feedback.** `IconButtonCommand` has `_isLoading`. The add modal has its `LoaderOverlay`. These are widget-local concerns, not provider state.
3. **`runCommand` / `handleAsyncCommand` for the try/catch + SnackBar.** One helper, reused at every command call site. Errors can never be forgotten.
4. **The store is the single source of truth.** Add or remove in one place, every derived view follows.
5. **Let `DiffUtilSliverList` handle the list animations.** Just give it keyed children and a builder for each animation type.

![add item](docs/add_item.jpg)
