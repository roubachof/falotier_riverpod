---
title: Loading from scratch with Riverpod, part 2: a sequence of AsyncValues
feature_image: ../../docs/loading_home.jpg
description: Real apps don't start with one async call — they start with a chain. Here is how to give your users a perfect, per-step loading feedback without the pyramid of doom.
tags:
  - flutter
  - riverpod
  - state-management
  - architecture
author: Piskariov
published_at: 2026-07-19
---

You open an app. You see... nothing. Or worse: a forever-spinning loader with no context. You wait two seconds. Five. You wonder if it's frozen. You close it.

We've all been there — as users. As developers, we keep shipping it.

In [part 1 of this series](https://www.sharpnado.com/falotier-riverpod), I showed how Riverpod's `AsyncValue` plus a tiny `AsyncValueWidget` gives you perfect loading/error/success feedback for the simplest case: one async call, one widget, one loading state.

But real apps don't have one async call. **They have a chain.**

When [falotier](https://github.com/sharpnado/falotier) cold-starts, four things must happen before I can show a single street lamp:

1. Initialize the domain (mock data, in-memory stores, etc.)
2. Fetch the available city zones from the repository
3. Resolve the default selected zone (the first one)
4. Load the lamps for that zone

Each step depends on the previous one. If step 1 fails, you can't even try step 2. And the user wants to know *what* is loading at every moment — not stare at a generic spinner.

This post is the sequel: **how to compose `AsyncValue`s into a cascade, give each step its own loading message and targeted retry button, and not lose your mind in the process.**

---

## The shape of the problem

Here is what the user goes through when opening falotier:

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

Looks like a feather duster (*plumeau*, as my French brain insists on calling it) — narrow handle at the top, fan of states opening at every step. The success branch keeps cascading. The error branch short-circuits to the retry button.

The non-negotiable requirements:

- **Each step shows its own loading message.** "Initializing the app", then "Loading the available zones", then "loading street lamps". A blank spinner is a UX failure.
- **Each step has its own retry action.** If step 3 fails, the retry button re-runs step 3 — not the whole chain. The user shouldn't have to wait through steps 1 and 2 again because step 3 had a network blip.
- **No nesting explosion.** Add a 4th step tomorrow, the code structure shouldn't change.

---

## The naive solution (and why it doesn't scale)

If we just chained `AsyncValue.when()` calls, we'd write this:

```dart
return domainInitializerAsync.when(
  loading: () => const AppLoadingWidget(message: 'Initializing the app'),
  error: (e, s) => AppErrorWidget(
    e.toString(),
    () => ref.read(domainInitializerProvider.notifier).reload(),
  ),
  data: (_) => selectedZoneAsync.when(
    loading: () => const AppLoadingWidget(message: 'Loading the available zones'),
    error: (e, s) => AppErrorWidget(
      e.toString(),
      () => ref.read(selectedZoneProvider.notifier).reload(),
    ),
    data: (_) => lampListAsync.when(
      loading: () => const AppLoadingWidget(message: 'loading street lamps'),
      error: (e, s) => AppErrorWidget(
        e.toString(),
        () => ref.read(lampListProvider.notifier).reload(),
      ),
      data: (lamps) => LampListView(lamps),
    ),
  ),
);
```

This works. For 3 steps. Add a 4th and you're at 6 levels of nesting. Add a 5th and you can't see your real UI anymore — it's buried at the bottom of a Russian doll of `when()` calls, behind three layers of curly braces.

It's also deeply repetitive: the same `loading` / `error` pattern at every level, only the message and retry callback differ. And if you want the same cascade in another screen, you copy-paste the whole thing.

There must be a better way.

---

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
  /// one is even considered. Each renders its own loading message and its own
  /// error retry button.
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

Each node wraps its child in an `AsyncValueWidget` (the one from [part 1](https://www.sharpnado.com/falotier-riverpod)). When the node's `AsyncValue` is `loading`, the loading widget shows — with **this node's message**. When `error`, the error widget shows — with **this node's retry button**. When `data`, the child is rendered, which recursively is the next node's widget.

The end result is exactly the cascade from the diagram: each step owns its loading message and retry button, the chain stops at the first non-success state, and the leaf's data widget only renders when every step above it has succeeded.

The clever bit is the **backward construction**. We start from the leaf (the final UI we want to render) and wrap it in each node from last to first. So when you read the `build` method, it looks like inside-out — but conceptually, each `AsyncValueWidget` is asking "am I loading? Then I take over. Am I error? Then I take over. Otherwise, I defer to my child."

---

## The actual call site in falotier

Here's `StreetLampList`, the home screen of falotier. It declares the cascade in a flat, declarative way — **no nesting**:

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

Read top to bottom, this **is** the cascade: init domain → resolve selected zone → load lamp list → render the list.

Add a 4th prerequisite tomorrow? Just append a node at the bottom of `nodes`. No restructuring, no extra nesting, no fear.

---

## Why this fits Riverpod like a glove

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

The `AsyncValueSequenceWidget` isn't doing anything clever — it's just **rendering the graph** the way Riverpod already structures it. The cascade is in your providers; the widget surfaces it.

---

## A note on the retry buttons

You might have noticed: each node's `onErrorButtonTap` calls the `.notifier.reload()` of **that specific provider**. Not a global "retry everything" button.

This matters more than it looks. Imagine step 3 (loading lamps) fails because of a network blip. The user taps Retry. We re-run step 3. Steps 1 and 2 have already succeeded — their providers still hold their data — so they don't re-fetch. The retry is **surgical**.

If we'd built a single mega-provider that loads everything end-to-end, every retry would re-run the whole chain. The user would wait through "Initializing the app" again, even though the domain is already initialized. Annoying.

This is a small but real win from decomposing your loading state into per-step `AsyncValue`s: **failures are local, retries are local.**

---

## To sum up

1. **Identify the sequential loading chain** at app start. List the steps that must succeed in order before you can render your final widget.
2. **Assign each step its own message and retry action.** Users want to know what's loading and why; the retry button should target the failing step, not the whole chain.
3. **Use `AsyncValueSequenceWidget`** to declare the cascade flatly instead of nesting `when()` calls.
4. **Compose with the `AsyncValueWidget` from part 1.** The sequence is just a chain of `AsyncValueWidget`s, each wrapping the next.

You get a perfect, per-step user feedback loop, with no indentation explosion, and a structure that grows linearly with the depth of your dependency chain.

![cascade](../docs/loading_home.jpg)

---

## What's next

In the next post, we'll tackle the **refreshing** case: the user has already loaded the list, they pull-to-refresh, and we want to:

- show the refresh indicator only if nothing is currently loading,
- on success, silently update the list,
- on error, leave the existing list untouched and surface a SnackBar.

The pattern is different from the cold-start cascade, and Riverpod has a few surprises in store (good ones). [Subscribe](https://www.sharpnado.com/#/portal/signup) to know when it drops.

And if you want to read the code directly in the meantime, [falotier is open-source](https://github.com/sharpnado/falotier). The architecture has been refined through several iterations — there's a `proposed_improvements/` folder at the root with a `validated/` and `implemented/` subfolder showing the lifecycle of each refactoring decision. Worth a browse.

Don't resist Riverpod: embrace it. 🙂
