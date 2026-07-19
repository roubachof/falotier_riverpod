# Consolidation du pattern commande en v2 — minimal, sans Mutation custom

> **Phase 1, faisable en v2 aujourd'hui.** Ce doc complète `normalized_entity_store.md` : le store unifie **où** vivent les mutations, ce doc unifie **comment** la UI les appelle.
>
> **S'arrête exprès avant `Mutation` v3.** La consolidation ici est cosmétique — factoriser le try/catch/finally dupliqué, unifier la stratégie sur 100% pessimiste. On ne construit **pas** un sealed state d'action custom, **pas** de provider d'action. Ça, c'est le job de `Mutation` v3 plus tard (voir `mutation_v3.md`), et le réinventer maintenant c'est du travail jetable.

## Objectif

Trois problèmes dans le code actuel :

1. **Duplication du try/catch/finally.** `IconButtonCommand._internalOnPressed`, `LitLampWidget._onTap`, et `handleAsyncCommand` (`loading_states_widgets.dart:23`) répètent le même squelette : set loading → await → catch `handleCommandError` → finally reset loading.
2. **Stratégies de mutation incohérentes.** `ZoneStreetLamps.addOrUpdate` est pessimiste (`await` repo avant `update`), l'ancien `LampDetails.toggle` était optimiste sans rollback. Sur la même entité. On unifie sur **100% pessimiste** (voir section 2).
3. **État d'action dispersé.** `_isLoading` en `StatefulWidget` local dans `IconButtonCommand` et `LitLampWidget`, `LoaderOverlay` impératif dans `street_list`. Pas de point unique pour "une commande est-elle en cours".

La consolidation v2 adresse 1 et 2. Le 3 reste — c'est précisément ce que `Mutation` v3 résoudra, et on l'attend.

## 1. Le helper `runCommand` — factoriser le try/catch/finally

### Before — dupliqué trois fois

`IconButtonCommand` (`lib/presentation/home/icon_button_command.dart:44`) :

```dart
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
```

`LitLampWidget._onTap` (`lib/presentation/street_lamp_details/lit_lamp_widget.dart:104`) — même squelette + animations :

```dart
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
```

`handleAsyncCommand` (`lib/presentation/common/loading_states_widgets.dart:23`) — version overlay + onSuccess :

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

### After — un seul helper + callbacks

Extraire le squelette commun dans `loading_states_widgets.dart`. L'état de loading reste widget-local (c'est le point que Mutation v3 résoudra plus tard — on ne le nie pas, on l'attend), mais le try/catch/finally est factorisé.

```dart
/// Exécute une commande async avec gestion d'erreur centralisée.
/// [onLoadingStart] / [onLoadingEnd] laissent le widget piloter son feedback
/// (spinner local, overlay, animation). L'erreur remonte toujours via
/// handleCommandError → SnackBar.
Future<void> runCommand({
  required BuildContext context,
  required Future Function() action,
  FutureOr Function()? onSuccess,
  void Function()? onLoadingStart,
  void Function()? onLoadingEnd,
}) async {
  if (onLoadingStart != null) onLoadingStart();
  try {
    await action();
    if (onSuccess != null) await onSuccess();
  } catch (e, t) {
    handleCommandError(context, e, t);
  } finally {
    if (onLoadingEnd != null) onLoadingEnd();
  }
}
```

`IconButtonCommand` devient :

```dart
Future _internalOnPressed(BuildContext context) async {
  await runCommand(
    context: context,
    action: widget.onPressed,
    onLoadingStart: () => setState(() => _isLoading = true),
    onLoadingEnd: () => setState(() => _isLoading = false),
  );
}
```

`LitLampWidget._onTap` :

```dart
_onTap() async {
  Feedback.forTap(context);
  await runCommand(
    context: context,
    action: () async {
      if (widget.isLit) { _isTurningOff = true; } else { _isTurningOn = true; }
      await ref.read(lampDetailsProvider(lampId: widget.id).notifier).toggle();
    },
    onLoadingStart: () => setState(() => _isLoading = true),
    onLoadingEnd: () {
      _isTurningOff = _isTurningOn = false;
      if (mounted) setState(() { _isLoading = false; });
    },
  );
}
```

`handleAsyncCommand` se réécrit au-dessus de `runCommand` :

```dart
handleAsyncCommand({
  required BuildContext context,
  required Future Function() future,
  FutureOr Function()? onSuccess,
  bool showOverlay = false,
}) {
  return runCommand(
    context: context,
    action: future,
    onSuccess: onSuccess,
    onLoadingStart: showOverlay
        ? () => OverlayControllerWidget.of(context)?.setOverlayVisible(true)
        : null,
    onLoadingEnd: showOverlay
        ? () => OverlayControllerWidget.of(context)?.setOverlayVisible(false)
        : null,
  );
}
```

**Gain** : plus aucune duplication du `try/catch/finally` + `handleCommandError`. L'erreur ne peut plus être "oubliée" — `runCommand` l'attrape toujours. Et `handleAsyncCommand` reste pour la compat, juste minceur.

**Ce qu'on ne fait pas** : pas de `AsyncCommandState` sealed, pas de `CommandProvider`, pas de `ref.watch(commandState)`. L'état de loading reste `setState` local. C'est le line qu'on ne traverse pas en v2.

## 2. Stratégie unifiée : 100% pessimiste

> **Décision :** toutes les mutations sont pessimistes. Pas d'optimiste, pas de rollback. Pourquoi ?
>
> 1. **Les animations UI locales donnent déjà un feedback instantané pendant l'attente serveur.** `LitLampWidget` joue sa flame animation via `_action` (20s de croissance), `street_list` affiche un overlay global pendant le remove. L'utilisateur voit tout de suite que quelque chose se passe.
> 2. **L'optimiste n'apporte rien visuellement pendant la transition.** Dans `LitLampWidget._buildFlame`, le `switch (_action)` drive l'animation — la valeur de `widget.isLit` est ignorée pendant la transition. Flipper `isLit` en optimiste serait invisible.
> 3. **L'optimiste ajoute du code sans valeur métier.** try/catch + rollback + `rethrow` sur chaque mutation, pour un effet visuel nul.
> 4. **Le rollback d'un remove est jarring.** Item qui disparaît puis réapparaît parce que le serveur a échoué → clignotement désagréable. Avec overlay pessimiste, l'utilisateur voit un spinner, l'item reste, puis disparaît proprement.
>
> Le pessimisme est le défaut sain. La source de vérité reste le serveur. Pas de drift possible.

### Add — pessimiste (pas le choix)

Tu as besoin de l'ID serveur avant de mettre dans le store.

```dart
// dans StreetLampStore
Future add(Street street) async {
  final lamp = StreetLamp.fromStreet(street);
  final saved = await _repo.addOrUpdate(lamp);   // pessimiste : on attend l'ID
  state = AsyncData({...state.value!, saved.id: saved});
}
```

La UI montre un overlay global pendant l'attente (déjà le cas via `LoaderOverlay` dans `street_list.dart:24`).

### Remove — pessimiste

L'overlay global reste visible pendant l'appel serveur, l'item reste dans la liste, puis est retiré quand le serveur confirme.

```dart
// dans StreetLampStore
Future remove(String id) async {
  final lamp = state.value![id]!;
  await _repo.remove(lamp);                       // pessimiste : on attend la confirmation
  state = AsyncData({...state.value!}..remove(id));
}
```

La UI : `IconButtonCommand` devient spinner (comme aujourd'hui via `_isLoading`), l'overlay global est visible, l'item reste visible avec son animation de liste intacte. Quand le serveur confirme, le store retire l'item → la liste rebuild → l'animation de sortie de liste se joue naturellement.

Si le serveur échoue : rien n'a bougé côté store, l'overlay se ferme, la SnackBar s'affiche. Pas de restore à coder.

### Toggle — pessimiste

L'animation `_action` dans `LitLampWidget` donne déjà le feedback instantané. La donnée `isLit` flit quand le serveur confirme.

```dart
// dans StreetLampStore
Future toggle(String id) async {
  final previous = state.value!;
  final lamp = previous[id]!;
  final updated = lamp.copyWith(isLit: !lamp.isLit);
  await _repo.addOrUpdate(updated);               // pessimiste
  state = AsyncData({...previous, id: updated});  // une seule écriture, après succès
}
```

La UI : `_action = turningOn/turningOff` joue l'animation (feedback immédiat), `await store.toggle(id)`, `_action = idle`. Quand le serveur confirme, `widget.isLit` flit → rebuild → l'animation steady s'affiche. Si échec : `_action` repasse à `idle`, `widget.isLit` n'a pas bougé, la flame retourne à son état initial — pas de rollback à coder.

### Before — `StreetLampState.updateLight` (incohérent)

`lib/domain/street_lamps/providers.dart:67` — pessimiste côté liste (via `addOrUpdate`), mais l'ancien `LampDetails.toggle` (supprimé) faisait un flip optimiste sans rollback au-dessus. Donc tu avais un mixte : pessimiste côté liste, optimiste sans rollback côté détail. Trois états intermédiaires possibles.

### After — tout dans le store, cohérent et pessimiste

Le store centralise. `StreetLampState` (et l'ancien `LampDetails`) disparaissent (voir `normalized_entity_store.md`). La UI appelle `store.toggle(id)`, le store fait l'appel serveur puis met à jour l'état en une seule écriture. Toutes les vues (liste + détail + available streets) rebuildent de manière cohérente. Pas de sync cross-provider, pas de rollback, pas de trois-états.

## 3. Pourquoi on s'arrête là

Le test du "trop ou pas assez" pour la consolidation v2 :

| Si tu fais… | Verdict |
|---|---|
| Helper `runCommand` qui factorise try/catch/finally | ✅ minimal, permanent |
| Unifier sur 100% pessimiste (supprimer l'optimiste incohérent) | ✅ corrige un bug latent, permanent |
| Sealed `AsyncCommandState { idle, pending, error, success }` | ❌ c'est `Mutation` v3, tu le réinventes |
| `CommandProvider` qui expose l'état d'action au graphe | ❌ c'est `Mutation` v3 |
| `ref.watch(commandState)` dans les widgets | ❌ c'est `Mutation` v3 |

La ligne : **l'état d'action reste widget-local (`setState`) en v2.** On ne le pousse pas dans le graphe de providers. C'est précisément ce que `Mutation` v3 apportera — le faire custom maintenant c'est construire une abstraction qu'on jette à la migration.

Le helper `runCommand` est permanent : quand `Mutation` v3 land, `runCommand` disparaît au profit de `mutation.run(ref, ...)`, mais la logique métier (stratégie pessimiste cohérente) dans le store ne bouge pas. Donc le travail sur le store + la stratégie est durable ; seul le wrapper UI est jetable — et il est petit.

## 4. Position vs migration v3 Mutation plus tard

Cette consolidation est **compatible** avec `mutation_v3.md`, pas conflictuelle.

- Le store (`normalized_entity_store.md`) ne bouge pas à la migration v3 — il est indépendant de la version.
- La stratégie pessimiste dans le store ne bouge pas — `Mutation` tracke l'état d'action, ne décide pas de la stratégie.
- Le helper `runCommand` est remplacé par `mutation.run(ref, ...)` — mais c'est une recherche/remplace mécanique sur ~3 call sites.
- Les `_isLoading` widget-local sont remplacés par `ref.watch(mutation)` — c'est le gain que `mutation_v3.md` cas 1 et 2 décrivent.

Donc le travail d'aujourd'hui (store + stratégie + helper) **se conserve** à la migration. Seul le wrapper UI change. C'est exactement le découpage qu'il faut : durable côté domaine, jetable côté UI.

## 5. Checklist d'exécution

1. **Faire le store d'abord** (`normalized_entity_store.md`) — sans lui, les mutations n'ont pas de home centralisée.
2. **Migrer les mutations vers le store** — `add`, `remove`, `toggle`, toutes pessimistes. Pas de try/catch, pas de rollback.
3. **Supprimer `StreetLampState`** — ses méthodes vivent dans le store maintenant. (`LampDetails` est déjà supprimé.)
4. **Extraire `runCommand`** dans `loading_states_widgets.dart`.
5. **Réécrire `IconButtonCommand._internalOnPressed`** sur `runCommand`.
6. **Réécrire `LitLampWidget._onTap`** sur `runCommand` (animations locales inchangées via `FlameAction`, juste le try/catch qui part).
7. **Réécrire `handleAsyncCommand`** comme wrapper mince sur `runCommand` (garde la signature pour ne pas casser `street_list`).
8. **Tester les trois chemins d'erreur** : add fail (overlay se ferme, SnackBar), remove fail (rien n'a bougé, SnackBar), toggle fail (animation retourne à l'état initial, SnackBar).
9. **Commit**.

## Résumé de l'effort

| Étape | Travail | Permanent ? |
|---|---|---|
| Store normalisé | voir `normalized_entity_store.md` | ✅ |
| Stratégie 100% pessimiste | dans le store, pas de rollback | ✅ |
| Helper `runCommand` | factorise try/catch/finally | ⚠️ jetable à v3 Mutation |
| Réécriture 3 call sites | sur `runCommand` | ⚠️ jetable à v3 Mutation |
| Tests chemins d'erreur | validation | ✅ |

Le cœur (store + stratégie pessimiste) est permanent. Le wrapper UI (`runCommand` + `_isLoading` local) est jetable à la migration v3 — mais il est petit, et il corrige un vrai problème maintenant (duplication + oubli possible d'erreur) sans qu'on réinvente `Mutation`.

## Ce que cette consolidation ne fait pas (exprès)

- **Pas d'état d'action réactif global.** Si tu veux qu'un widget A montre "une suppression est en cours sur la lamp X" pendant que le widget B (la liste) fait autre chose, il te faut `Mutation` v3. En v2 avec `runCommand`, l'état d'action est local au widget qui déclenche. C'est la limite qu'on accepte pour ne pas réinventer.
- **Pas de multiple-call-site sur la même action.** Si deux widgets veulent déclencher le même `toggle` et partager l'état pending, v2 local ne le permet pas proprement. `Mutation(lamp.id)` v3 le fait via la clé. Limite acceptée.
- **Pas de succès observable.** `onSuccess` callback one-shot, pas `MutationSuccess` état qu'un widget peut afficher. Limite acceptée.

Ces trois limites sont **exactement** ce que `mutation_v3.md` cas 1 et 2 résoudront quand tu migreras. La consolidation v2 ne cherche pas à les adresser — elle cherche à nettoyer ce qui est nettoyable sans réinventer, et laisser le reste à v3.

## L'ordre des docs, révisé

1. **`normalized_entity_store.md`** — faire d'abord. Le store.
2. **`command_pattern_consolidation.md`** (ce doc) — faire ensuite. Les commands sur le store.
3. **`mutation_v3.md`** — plus tard, après migration v3. Remplace `runCommand` par `Mutation`.
4. **`migration_v3.md`** ou **`migration_v3_no_codegen.md`** — plus tard, quand tu migres la syntaxe. Voir la discussion sur #4752 : probablement attendre la syntaxe unifiée stable plutôt que migrer en v3.3.2 intermédiaire.

Phase 1 = docs 1 + 2, en v2, maintenant. Phase 2 = migration v3 + docs 3 + 4, plus tard.
