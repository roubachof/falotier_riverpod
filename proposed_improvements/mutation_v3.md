# Riverpod v3 `Mutation` vs ton pattern commande

## Contexte

Riverpod 3.0 (stable depuis septembre 2025, actuelle 3.3.x) introduit un objet `Mutation<T>` qui formalise **l'état d'une action** dans le graphe de providers — distinct de l'état d'une entité. C'est expérimental (import via `package:riverpod/experimental/...`), l'API peut casser sans major bump.

Ton pattern actuel (`handleAsyncCommand` + `IconButtonCommand` + `LitLampWidget._onTap`) est une **réimplémentation widget-local de Mutation** : tu avais anticipé le besoin — séparer l'état d'action réactif de l'état entité, gérer loading/error/success au niveau du call site — avant que Riverpod ne l'ajoute.

Ce document compare les deux, cas par cas, avec before/after, pour décider si/quoi migrer.

> **État actuel du repo** : branche `riverpod-v3` mais `pubspec.yaml` encore en v2 (`flutter_riverpod ^2.5.1`, `riverpod_annotation ^2.3.5`, `riverpod_generator ^2.4.3`). Migration des deps non démarrée.

## Le modèle `Mutation` v3 en bref

```dart
// déclaration top-level, comme un provider
final removeLampMutation = Mutation<void>();

// watch → sealed state exhaustif
final state = ref.watch(removeLampMutation(lamp.id));
switch (state) {
  case MutationIdle():
  case MutationPending():
  case MutationError(:final error):
  case MutationSuccess():
}

// trigger → met à jour l'état automatiquement
removeLampMutation(lamp.id).run(ref, () async {
  await ref.read(lampListProvider.notifier).remove(lamp);
});
```

Détails du design officiel :
- **Clé** via `mutation(key)` → état distinct par item (équivalent fonctionnel de ton `StreetLampState(id:)` mais pour l'état d'action).
- **Auto-reset à `MutationIdle`** quand plus personne n'écoute (autoDispose des actions).
- **Pas de contrôle de concurrence** — deux `run` simultanés possibles, à toi de désactiver le bouton en `MutationPending`.
- **Ne rollback pas l'état entité** — tracke succès/échec, mais c'est au notifier de remettre l'état. Orthogonal au normalized store.

## Cas 1 — Remove : `IconButtonCommand` → `Mutation` (bon fit)

### Before — `lib/presentation/home/icon_button_command.dart`

`StatefulWidget` + `_isLoading` booléen + `setState` + `handleCommandError` en catch. L'état d'action vit dans le widget.

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

  Future _internalOnPressed(BuildContext context) async {
    try {
      setState(() { _isLoading = true; });
      await widget.onPressed();
    } catch (error, stackTrace) {
      handleCommandError(context, error, stackTrace);
    } finally {
      setState(() { _isLoading = false; });
    }
  }
}
```

Call site dans `lib/presentation/home/street_lamp_list.dart:62` :

```dart
onRemove: () => ref.read(lampListProvider.notifier).remove(lamp),
```

avec le `IconButtonCommand` qui wrappe l'appel et gère le spinner local.

### After — `Mutation` avec clé par lamp

Plus de `StatefulWidget`, plus de `_isLoading`, plus de try/catch. L'état d'action est dans le graphe de providers, indexé par `lamp.id`.

```dart
// top-level, à côté des providers domain
final removeLampMutation = Mutation<void>();

class RemoveLampButton extends ConsumerWidget {
  final StreetLamp lamp;
  const RemoveLampButton({super.key, required this.lamp});

  @override
  Widget build(context, ref) {
    final theme = AppTheme.of(context);
    return switch (ref.watch(removeLampMutation(lamp.id))) {
      MutationIdle() => IconButton(
          color: theme.colors.foreground,
          icon: AppIcon.regular(Icons.close),
          onPressed: () {
            removeLampMutation(lamp.id).run(ref, () async {
              await ref.read(lampListProvider.notifier).remove(lamp);
            });
          },
        ),
      MutationPending() => AppPadding(
          padding: const AppEdgeInsets.regular(),
          child: SizedBox(
            height: theme.icons.sizes.regular,
            width: theme.icons.sizes.regular,
            child: const AppLoadingWidget(),
          ),
        ),
      MutationError()   => const SizedBox.shrink(), // SnackBar via listener global
      MutationSuccess() => const SizedBox.shrink(), // item retiré de la liste
    };
  }
}
```

Et le call site dans `street_lamp_list.dart` devient :

```dart
onRemove: null, // l'action vit dans le bouton
// ...
child: RemoveLampButton(lamp: lamp),
```

**Gains** : `ConsumerWidget` au lieu de `StatefulWidget`, plus de `mounted`, état d'action partagé entre toutes les occurrences de la même lamp (clé), erreur déportée vers listener global.

**Coût** : désactivation du bouton à expliciter (`MutationPending` ne garantie rien sur la concurrence). Ici le switch rend déjà un spinner au lieu du bouton, donc implicitement safe — mais à garder en tête si on remet un `IconButton` dans toutes les branches.

## Cas 2 — Add street : `handleAsyncCommand` + overlay + `onSuccess` → `Mutation` (fit partiel)

### Before — `lib/presentation/add_street/street_list.dart:69`

`handleAsyncCommand` gère overlay global + callback de succès + SnackBar d'erreur. Tout est dans un handler impératif.

```dart
_addStreet(BuildContext context, Street data, WidgetRef ref) {
  final streetLampNotifier = ref.watch(lampListProvider.notifier);
  final streetLamp = StreetLamp.fromStreet(data);
  handleAsyncCommand(
    context: context,
    future: () => streetLampNotifier.addOrUpdate(streetLamp),
    onSuccess: () => Navigator.pop(context),
    showOverlay: true,
  );
}
```

Et `handleAsyncCommand` dans `lib/presentation/common/loading_states_widgets.dart:23` :

```dart
handleAsyncCommand({
  required BuildContext context,
  required Future Function() future,
  FutureOr Function()? onSuccess,
  bool showOverlay = false,
}) async {
  try {
    if (showOverlay) {
      OverlayControllerWidget.of(context)?.setOverlayVisible(true);
    }
    await future();
    if (onSuccess != null) {
      await onSuccess();
    }
  } catch (e, t) {
    handleCommandError(context, e, t);
  } finally {
    if (showOverlay) {
      OverlayControllerWidget.of(context)?.setOverlayVisible(false);
    }
  }
}
```

### After — trigger + listener séparés

Le trigger ne fait que lancer l'action. Le succès/erreur/overlay se drive sur l'état réactif via `ref.listen`, centralisé.

Déclaration :

```dart
final addStreetMutation = Mutation<void>();
```

Trigger (dans le `onTap` du tile, `street_list.dart:54`) :

```dart
onTap: () {
  final streetLamp = StreetLamp.fromStreet(street);
  addStreetMutation.run(ref, () async {
    await ref.read(lampListProvider.notifier).addOrUpdate(streetLamp);
  });
},
```

Listener (dans la `AddStreetScreen` ou à la racine de l'app) :

```dart
ref.listen(addStreetMutation, (prev, next) {
  switch (next) {
    case MutationPending():
      OverlayControllerWidget.of(context)?.setOverlayVisible(true);
    case MutationSuccess():
      OverlayControllerWidget.of(context)?.setOverlayVisible(false);
      Navigator.pop(context);
    case MutationError(:final error):
      OverlayControllerWidget.of(context)?.setOverlayVisible(false);
      handleCommandError(context, error, StackTrace.current);
    case MutationIdle():
      break;
  }
});
```

**Gains** : plusieurs call sites peuvent déclencher `addStreetMutation.run` sans dupliquer la logique overlay/SnackBar/pop. Le succès est observable par n'importe quel widget (confirmation auto-dismissible).

**Coût** : le `Navigator.pop(context)` capturé dans le listener dépend du `context` du widget qui l'enregistre — si l'écouteur est à la racine, il faut soit garder le listener dans la modal, soit passer la route via `go_router` au lieu de `Navigator.pop`. Le couplage overlay→context reste.

## Cas 3 — Toggle lamp : `LitLampWidget` → on **garde** l'impératif local (mauvais fit)

### Before — `lib/presentation/street_lamp_details/lit_lamp_widget.dart:22`

Trois booléens locaux distincts : `_isLoading`, `_isTurningOn`, `_isTurningOff`. Ils pilotent **deux animations différentes** (flamme qui grandit vs s'éteint) en plus du loading générique.

```dart
class _LitLampWidgetState extends ConsumerState<LitLampWidget> {
  bool _isLoading = false;
  bool _isTurningOff = false;
  bool _isTurningOn = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoading || widget.isLit) {
      return Transform.translate(
        offset: const Offset(20, 0),
        child: Opacity(
          opacity: 0.7,
          child: InkWell(
            onTap: !_isLoading ? _onTap : null,
            child: _getAnimatedContainer(),
          ),
        ),
      );
    }
    return InkWell(
      onTap: _onTap,
      child: const SizedBox(height: 100, width: 80),
    );
  }

  _onTap() async {
    Feedback.forTap(context);
    try {
      if (widget.isLit) { _isTurningOff = true; } else { _isTurningOn = true; }
      setState(() { _isLoading = true; });
      await ref.read(lampDetailsProvider(lampId: widget.id).notifier).toggle();
    } catch (e, t) {
      handleCommandError(context, e, t);
    } finally {
      _isTurningOff = _isTurningOn = false;
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }
}
```

### After — on ne migre **pas** ce cas

Le modèle `Idle/Pending/Success/Error` de Mutation ne mappe pas sur deux animations directionnelles. Deux options si on voulait quand même :

**Option A — deux mutations**, une par direction :

```dart
final lightOnMutation = Mutation<void>();
final lightOffMutation = Mutation<void>();
```

Ça duplique la déclaration, le `switch`, et le synchro avec `widget.isLit` initial. Plus de code que le `_isTurningOn`/`_isTurningOff` actuel, pour zéro gain réactif — personne d'autre que ce widget n'observe l'état d'action du toggle.

**Option B — garder l'impératif local** (recommandé). L'animation se drive sur le changement de `widget.isLit` (qui provient du provider entité) plutôt que sur l'état d'action. Mais comme l'animation doit démarrer **avant** que le data flip, on reste sur le `setState` local.

**Conclusion cas 3** : `LitLampWidget` reste en impératif. Mutation n'apporte rien ici. Le seul nettoyage vaut le coup indépendamment de v3 : extraire un helper `runCommand({onLoading, onIdle})` pour factoriser le try/catch/finally qu'on retrouve aussi dans `IconButtonCommand`.

## Listener centralisé pour les SnackBars

Indépendamment des cas ci-dessus, le gros gain v3 est de déporter `handleCommandError` dans un `ref.listen` à la racine. Aujourd'hui chaque call site doit le rappeler manuellement (`street_list.dart:76`, `icon_button_command.dart:51`, `lit_lamp_widget.dart:118`).

### Before — `handleCommandError` rappelé partout

```dart
// dans chaque catch, dans chaque widget
catch (e, t) {
  handleCommandError(context, e, t);
}
```

### After — un seul listener à la racine

```dart
class App extends ConsumerWidget {
  @override
  Widget build(context, ref) {
    ref.listen(removeLampMutation, _showErrorSnackBar(context));
    ref.listen(addStreetMutation,  _showErrorSnackBar(context));
    ref.listen(lightOnMutation,     _showErrorSnackBar(context));
    // ... une ligne par mutation de l'app
    return MaterialApp.router(...);
  }
}

void Function(MutationState?, MutationState) _showErrorSnackBar(BuildContext context) {
  return (prev, next) {
    if (next is MutationError) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackBar.buildSnackBar(_errorToString(next.error), context),
      );
    }
  };
}
```

Plus aucune mutation ne peut "oublier" sa SnackBar. Et quand tu ajoutes une nouvelle mutation, c'est une ligne à la racine, pas un `try/catch` à dupliquer.

## Coût de la migration v3 elle-même

Adopter `Mutation` suppose d'abord de passer en v3. Plusieurs breaking changes du changelog te touchent directement :

### Familles → **pas de refactor manuel en codegen** (correction)

`FamilyNotifier`/`FamilyAsyncNotifier` sont supprimés en hand-written. Mais falotier utilise le codegen (`@riverpod`), et le mainteneur le confirme dans le RFC #4218 :

> Code generation is not impacted and we'd still be defining parameters on `Notifier.build` instead.

Donc tes families **gardent `build({required X arg})`** tel quel :

```dart
@Riverpod(keepAlive: true)
class ZoneStreetLamps extends _$ZoneStreetLamps {
  @override
  Future<IList<StreetLamp>> build({required CityZone zone}) async {
    final repository = ref.watch(streetLampRemoteRepositoryProvider);
    final lamps = await repository.getList(zone);
    return lamps.sort(streetLampComparator);
  }
}
```

C'est le `.g.dart` qui change de forme en dessous (suppression des mixins `*Ref`, des `BuildlessAsyncNotifier`, des préfixes `AutoDispose`), pas ta source. Idem pour `StreetLampState(id:)`, `AvailableStreets(zone:)`, `streets(zone:)`, `LampDetails(lampId:)`. Les call sites `provider(zone: x)` ne bougent pas non plus.

Le refactor `class X(this.arg); build()` ne s'applique qu'au hand-written. Voir `migration_v3.md` pour la marche à suivre complète.

### Automatic retry par défaut — piège sur ton mock

Les providers qui failent sont retry automatiquement avec backoff exponentiel (200ms → 6.4s). Ton `getList` à `exceptionProbability: 1` (`lib/domain/street_lamps/impl/remote_repository_mock.dart:66`) va se faire retry indéfiniment au lieu d'afficher l'état d'erreur.

After — désactiver le retry sur ce provider :

```dart
@Riverpod(keepAlive: true, retry: (_, __) => null)
class ZoneStreetLamps extends _$ZoneStreetLamps { ... }
```

Ou globalement sur le `ProviderScope` dans `lib/app.dart` :

```dart
ProviderScope(
  retry: (_, __) => null, // PoC : on veut voir l'erreur, pas retry
  child: ...,
)
```

### Autres points de friction

- **`*Ref` subclasses supprimés** (`AvailableZonesRef`, `StreetsRef`, `ZoneStreetLampsRef`...) → `Ref` partout. Codegen régénère différemment.
- **Providers hors vue mis en pause** par défaut — peut interagir avec ton `keepAlive` de cache (à valider au runtime).
- **`ProviderException` wrapping** : si tu catchais des erreurs typées via `.future`, tu dois maintenant `on ProviderException catch (e) { if (e.exception is ItemNotFoundException) ... }`. Pas d'impact si tu passes par `AsyncValue.error` (ton cas).
- **`StateProvider`/`StateNotifierProvider`/`ChangeNotifierProvider`** déplacés en `legacy.dart` — pas d'impact, tu n'en utilises pas.

## Recommandation

Sur falotier en l'état (1 zone, 8 lamps, v2 stable) : **ne migre pas juste pour Mutation**. Le coût family→constructeur touche tout le domaine pour un bénéfice UI marginal sur un PoC. Ton pattern commande est idiomatique v2 et fonctionne.

Si tu migres quand même (légitime sur cette branche dédiée) :

1. **D'abord la migration mécanique** — familles → constructeur, `Ref` unifié, retry à désactiver sur le mock error. Faire compiler.
2. **Réfléchir au normalized store AVANT Mutation** — c'est le plus gros gain structurel (voir `normalized_entity_store.md`), et il est indépendant de v3. Le toggle incohérent list-vs-detail ne se règle pas avec Mutation, seulement avec le store.
3. **Adopter Mutation sur un seul flow simple** (le remove, cas 1) pour juger la DX en vrai avant de généraliser.
4. **Garder `LitLampWidget` en impératif local** (cas 3) — Mutation n'aide pas son animation.
5. **Centraliser le `ref.listen` SnackBar à la racine** pour ne plus jamais appeler `handleCommandError` à la main.

L'ordre importe : normalized store → v3 mécanique → Mutation. Inverser les deux premiers, c'est migrer du code qu'on va re-refactor juste après.

## Références

- Doc officielle `Mutation` : https://pub.dev/documentation/riverpod/latest/experimental_mutation/Mutation-class.html
- What's new 3.0 : https://riverpod.dev/docs/whats_new
- Migration 2.0 → 3.0 : https://riverpod.dev/docs/3.0_migration
- Changelog : https://github.com/rrousselGit/river_pod/blob/master/packages/riverpod/CHANGELOG.md
