# Loading from scratch part 2: a sequence of `AsyncValue`s

> This is the second case of the [Loading from scratch](load_from_scratch.md) series.
>
> - [**Case 1**](load_from_scratch.md) — Simplest use case: only one dependency.
> - **Case 2 (this doc)** — Multiple sequential dependencies, each with its own loading message and error retry.

## The use case

In [Case 1](load_from_scratch.md) we loaded a list of street lamps from a single repository call. One `AsyncValue`, one widget, one loading state, done.

But real apps don't start with one async call. They start with a chain.

When falotier cold-starts, before we can show the lamp list, **four** things must happen one after the other:

1. **Initialize the domain** (mock data, in-memory stores, etc.)
2. **Fetch the available city zones** from the city zone repository
3. **Resolve the selected zone** (the first one by default)
4. **Load the lamps for that zone** (which then powers the list)

Each step depends on the previous one. If step 1 fails, you can't even try step 2. If step 3 succeeds but step 4 fails, you want a Retry button that re-runs step 4 — not the whole chain.

And crucially: **the user must understand what's happening at every moment.** A blank spinner for 3 seconds with no context is bad UX. The user wants to read *"Initializing the app"*, then *"Loading the available zones"*, then *"Loading street lamps"*. Each step has its own message.

If any step fails, we show the error widget with the **specific retry action for that step**. Not a generic "try again" that re-runs everything.

## The loading cascade

Here is the shape of the cascade the user goes through when opening the app:

```
                          App cold start
                                │
                                ▼
                ┌───────────────────────────────┐
                │  STEP 1                       │
                │  DomainInitializer            │  "Initializing the app"
                │  (mock data, stores init)     │
                └───────────────┬───────────────┘
                                │
                ┌───────────────┼───────────────┐
                ▼               ▼               ▼
             loading          error          success
              │                 │               │
              │        ┌────────────────────┐   │
              │        │ ❌ Error widget    │   │
              │        │ + "Retry" button   │   │
              │        │ → retries step 1   │   │
              │        └────────────────────┘   │
              │                                  │
              └──────────────┐    ┌──────────────┘
                             ▼    ▼
                ┌───────────────────────────────┐
                │  STEP 2                       │
                │  SelectedZone                 │  "Loading the available zones"
                │  (fetches zones + picks #1)   │
                └───────────────┬───────────────┘
                                │
                ┌───────────────┼───────────────┐
                ▼               ▼               ▼
             loading          error          success
              │                 │               │
              │        ┌────────────────────┐   │
              │        │ ❌ Error widget    │   │
              │        │ + "Retry" button   │   │
              │        │ → retries step 2   │   │
              │        └────────────────────┘   │
              │                                  │
              └──────────────┐    ┌──────────────┘
                             ▼    ▼
                ┌───────────────────────────────┐
                │  STEP 3 (leaf)                │
                │  LampList                     │  "loading street lamps"
                │  (store loads zone's lamps)   │
                └───────────────┬───────────────┘
                                │
                ┌───────────────┼───────────────┐
                ▼               ▼               ▼
             loading          error          success
              │                 │               │
              │        ┌────────────────────┐   │
              │        │ ❌ Error widget    │   │
              │        │ + "Retry" button   │   │
              │        │ → retries step 3   │   │
              │        └────────────────────┘   │
              │                                  │
              └──────────────┐    ┌──────────────┘
                             ▼    ▼
                ┌───────────────────────────────┐
                │  ✅ Result                    │
                │  The lamp list (DiffUtil)     │
                └───────────────────────────────┘
```

Looks like a plumeau turned upside down — narrow handle at the top, fan of states opening at every step. The success branch keeps cascading; the error branch shortcuts to the retry button.

> Note: the cascade has 3 *visible* steps in the widget (`domainInitializer` → `selectedZone` → `lampList`), but the full chain is actually 5 deep if you count hidden sub-dependencies: `domainInitializer` → `availableZones` → `selectedZone` → `streetLampStore` → `lampList`. They're hidden because `availableZones` is consumed inside `selectedZone`'s `build()`, and the store is consumed inside `lampList`'s `build()`. We only surface in the UI the steps that have their own user-facing loading message and retry action.

## The naive solution: nested `when()` (pyramid of doom)

If we just chained `AsyncValue.when()` calls, we'd get this:

```dart
return domainInitializerAsync.when(
  loading: () => const AppLoadingWidget(message: 'Initializing the app'),
  error: (e, s) => AppErrorWidget(e.toString(), () => ref.read(domainInitializerProvider.notifier).reload()),
  data: (_) => selectedZoneAsync.when(
    loading: () => const AppLoadingWidget(message: 'Loading the available zones'),
    error: (e, s) => AppErrorWidget(e.toString(), () => ref.read(selectedZoneProvider.notifier).reload()),
    data: (_) => lampListAsync.when(
      loading: () => const AppLoadingWidget(message: 'loading street lamps'),
      error: (e, s) => AppErrorWidget(e.toString(), () => ref.read(lampListProvider.notifier).reload()),
      data: (lamps) => LampListView(lamps),
    ),
  ),
);
```

This works. But:

- **Indentation grows with depth.** Add a 4th step and you're at 6 levels of nesting.
- **Repetitive.** Same `loading`/`error` pattern at every level, only the message and retry callback differ.
- **Hard to read.** The actual UI you want to render (`LampListView`) is buried at the bottom of a Russian doll.
- **No reuse.** Want the same cascade in another screen? Copy-paste.

There must be a better way.

## The `AsyncValueSequenceWidget` solution

We introduce a small composition helper that takes a list of `AsyncValueSequenceNode` (the prerequisite steps) and a single `AsyncValueSequenceLeaf<T>` (the final step that produces the data we want to display), and renders the right widget for whichever state the cascade is currently in.

```dart
class AsyncValueSequenceWidget<T> extends StatelessWidget {
  const AsyncValueSequenceWidget({
    super.key,
    this.asSlivers = false,
    this.containerHeight = 300,
    required this.nodes,
    required this.leaf,
  });

  /// The prerequisite steps, in order. Each must reach `data` before the next
  /// one is even considered. Each can render its own loading message and
  /// its own error retry button.
  final List<AsyncValueSequenceNode> nodes;

  /// The final step that produces the value rendered by [leaf.childBuilder].
  final AsyncValueSequenceLeaf<T> leaf;

  final bool asSlivers;
  final double containerHeight;

  @override
  Widget build(BuildContext context) {
    // Build the sequence backward: start from the leaf, wrap it in each node.
    // The first node (from the end) that is loading or error short-circuits
    // and renders its own state instead of its child.
    var nextWidget = leaf.toWidget(
      asSlivers: asSlivers,
      containerHeight: containerHeight,
    );
    for (final node in nodes.reversed) {
      nextWidget = node.toWidget(
        nextWidget,
        asSlivers: asSlivers,
        containerHeight: containerHeight,
      );
    }
    return nextWidget;
  }
}
```

Each node wraps its child in an `AsyncValueWidget` (the one from [Case 1](load_from_scratch.md)). When the node's `AsyncValue` is `loading`, the loading widget shows (with this node's message). When `error`, the error widget shows (with this node's retry button). When `data`, the child is rendered — which recursively is the next node's widget.

The end result is exactly the cascade from the diagram: each step owns its loading message and retry button, the chain stops at the first non-success state, and the leaf's data widget only renders when every step above it has succeeded.

## How it looks in falotier

`StreetLampList` is the actual call site for the home screen. It declares the cascade in a declarative, flat way — no nesting:

```dart
class StreetLampList extends ConsumerWidget {
  const StreetLampList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueSequenceWidget<IList<StreetLamp>>(
      asSlivers: true,
      nodes: [
        AsyncValueSequenceNode(
          ref.watch(domainInitializerProvider),
          onErrorButtonTap: () =>
              ref.read(domainInitializerProvider.notifier).reload(),
          loadingMessage: 'Initializing the app',
          nodeName: 'domainInitializerNode',
        ),
        AsyncValueSequenceNode(
          ref.watch(selectedZoneProvider),
          onErrorButtonTap: () =>
              ref.read(selectedZoneProvider.notifier).reload(),
          loadingMessage: 'Loading the available zones',
          nodeName: 'selectedZoneNode',
        ),
      ],
      leaf: AsyncValueSequenceLeaf<IList<StreetLamp>>(
        ref.watch(lampListProvider),
        onErrorButtonTap: () => ref.read(lampListProvider.notifier).reload(),
        loadingMessage: 'loading street lamps',
        leafName: 'lampListLeaf',
        childBuilder: (data) {
          return DiffUtilSliverList.fromKeyedWidgetList(
            children: data.map((lamp) => /* ... lamp tile ... */).toList(),
            // ... animations ...
          );
        },
      ),
    );
  }
}
```

Read top to bottom, this is the cascade: init domain → resolve selected zone → load lamp list → render the list. Add a 4th prerequisite tomorrow? Just append a node. No restructuring, no extra nesting.

## Why this works well with Riverpod

The cascade maps 1:1 to a chain of Riverpod providers watching each other:

```
domainInitializerProvider
        │ ref.watch(...future)
        ▼
selectedZoneProvider            (watches availableZonesProvider internally)
        │ ref.watch(...future)
        ▼
streetLampStoreProvider         (watches selectedZoneProvider.future)
        │ ref.watch(zoneLamps(zone:).future)
        ▼
lampListProvider                (the leaf)
```

Each provider is async, so each emits an `AsyncValue`. The widget just observes each `AsyncValue` in order and renders the first non-success state. If `selectedZoneProvider` is loading, we don't even need to look at `lampListProvider` — we know we can't have lamps if we don't know which zone yet.

This is exactly what Riverpod's reactive graph is good at: each provider re-runs only when its dependencies produce new data, and the widget tree mirrors that graph.

## To sum up

1. **Identify the sequential loading chain** at app start. List the steps that must succeed in order before you can render your final widget.
2. **Assign each step its own message and retry action.** Users want to know what's loading and why; the retry button should target the failing step, not the whole chain.
3. **Use `AsyncValueSequenceWidget`** to declare the cascade flatly instead of nesting `when()` calls.
4. **Compose with the `AsyncValueWidget` from Case 1.** The sequence is just a chain of `AsyncValueWidget`s, each wrapping the next.

You get a perfect, per-step user feedback loop, with no indentation explosion, and a structure that grows linearly with the depth of your dependency chain.

![cascade](docs/loading_home.jpg)
