# Social posts — Loading from scratch, part 2 (a sequence of AsyncValues)

Source: [blog/loading-from-scratch-sequence.md](../loading-from-scratch-sequence.md)

---

## LinkedIn

Your app doesn't start with one async call.

It starts with a chain.

Initialize the domain. Fetch the zones. Resolve the default zone. Load the lamps for that zone. Then — only then — you can show the UI.

Four sequential dependencies at cold-start. Each step can fail. Each step deserves its own loading message and its own retry button.

The naive solution is to nest `AsyncValue.when()` calls. It works. For 3 steps. Add a 4th and you're at 6 levels of indentation. Your real UI is buried at the bottom of a Russian doll.

I just published a post on how falotier handles this case with a small composition helper: `AsyncValueSequenceWidget`. You declare the cascade flatly — one node per prerequisite step, one leaf for the final result — and the helper renders the right widget for whichever state the cascade is currently in.

Each step owns its loading message ("Initializing the app", then "Loading the available zones", then "loading street lamps"). Each step owns its retry button (re-runs only that step, not the whole chain). Add a 4th prerequisite tomorrow? Append a node. No restructuring.

The whole thing maps 1:1 to Riverpod's reactive provider graph. The widget is just rendering what the graph already structures.

Full write-up with diagrams and code samples: https://sharpnado.com/loading-from-scratch-sequence/

#flutter #riverpod #statemanagement #mobiledevelopment #dart

---

## Reddit (r/FlutterDev)

**Title:** Cold-start loading with 4 sequential async deps — here's how I structure it without the `when()` pyramid of doom

**Body:**

When your app cold-starts, you rarely have a single async call. You have a chain: init domain → fetch zones → resolve selected zone → load lamps → finally render the list.

Each step depends on the previous one. Each step can fail. Each step deserves its own user-facing loading message and its own retry action.

The classic approach is nested `AsyncValue.when()`:

```dart
domainAsync.when(
  data: (_) => zoneAsync.when(
    data: (_) => lampListAsync.when(
      data: (lamps) => LampList(lamps),
      ...
    ),
  ),
);
```

Works for 3 steps. Doesn't scale.

I wrote up the helper I use instead: `AsyncValueSequenceWidget`. You declare the cascade as a flat list of nodes + a leaf, and it renders the right widget based on whichever step is currently loading/error.

Key bits:
- Per-step loading messages ("Initializing the app" / "Loading zones" / ...)
- Per-step retry buttons (only the failing step re-runs, not the whole chain)
- Grows linearly: add a 4th prerequisite tomorrow, just append a node
- Maps 1:1 to the Riverpod reactive provider graph

Full write-up with the cascade diagram + code (it's the latest in my falotier Riverpod series):

https://sharpnado.com/loading-from-scratch-sequence/

Source code: https://github.com/roubachof/falotier

Curious how others here handle multi-step cold-start loading — do you nest, build a state machine, or use a similar composition helper?

---

## BlueSky

Your app doesn't start with one async call. It starts with a chain.

Init domain → fetch zones → resolve selected → load lamps. Each step can fail. Each step needs its own loading message + retry button.

New post on how falotier handles this with a tiny `AsyncValueSequenceWidget` (no `when()` pyramid of doom):

sharpnado.com/loading-from-scratch-sequence/

#flutter #riverpod
