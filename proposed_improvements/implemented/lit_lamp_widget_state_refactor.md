# Refacto de l'état du `LitLampWidget` : un seul enum d'action

> **Validé, à faire.** Portée : `lib/presentation/street_lamp_details/lit_lamp_widget.dart` uniquement.
>
> **Indépendante** de `command_pattern_consolidation.md` et `normalized_entity_store.md`. Peut se faire en v2 aujourd'hui. Se combine bien avec les deux plus tard.

## Problème

`_LitLampWidgetState` encode une machine à états avec **3 booléens mutuellement exclusifs** sans le dire :

```dart
bool _isLoading = false;
bool _isTurningOff = false;
bool _isTurningOn = false;
```

Combinés avec `widget.isLit` (depuis la data), ça fait théoriquement **2 × 2 × 2 × 2 = 16 états combinatoires**, dont la majorité n'a aucun sens. Aucune garantie statique que `_isTurningOn` et `_isTurningOff` ne soient jamais vrais ensemble.

Conséquences dans le code actuel :

- `build` commence par `if (_isLoading || widget.isLit)` — opaque, mélange "la data dit allumée" et "une action transition est en cours".
- `_getAnimatedContainer()` enchaîne 3 `if` sur ces booléens, avec un path implicite (la pulse loop) qui est le fallback.
- `_onTap` fait `_isTurningOff = _isTurningOn = false` dans le `finally` — deux writes couplés qui doivent rester synchronisés.
- Le `if (mounted) setState(...)` existe parce qu'on reset plusieurs flags ensemble après un await.

## La vraie machine à états

Le widget a **4 états visuels** :

```
        tap (off→on)            server OK
   off ────────────────► turningOn ──────────► lit
   ▲                                             │
   │                                             │ tap (on→off)
   │ server OK / fail                            │
   └─────── turningOff ◄─────────────────────────┘
```

Pendant la transition (await du toggle), on joue l'animation directionnelle. Hors transition, on affiche l'état stable piloté par la data (`widget.isLit`).

## Solution : un seul enum d'action

Remplacer les 3 booléens par **un seul enum à 3 valeurs** (idle encode les deux états stables via `widget.isLit`) :

```dart
enum FlameAction { idle, turningOn, turningOff }
```

État impossible à exprimer invalidement : `_action` ne peut valoir qu'une valeur à la fois.

### Le widget refactored

```dart
class _LitLampWidgetState extends ConsumerState<LitLampWidget> {
  FlameAction _action = FlameAction.idle;

  static const _turnOnDuration  = Duration(seconds: 20);
  static const _turnOffDuration = Duration(seconds: 2);
  static const _pulseDuration   = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    final isTransitioning = _action != FlameAction.idle;
    final showFlame = widget.isLit || isTransitioning;

    if (!showFlame) {
      return InkWell(
        onTap: _onTap,
        child: const SizedBox(height: 100, width: 80),
      );
    }

    return Transform.translate(
      offset: const Offset(20, 0),
      child: Opacity(
        opacity: 0.7,
        child: InkWell(
          onTap: isTransitioning ? null : _onTap,
          child: _buildFlame(),
        ),
      ),
    );
  }

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
          .fade(duration: const Duration(seconds: 5), begin: 1.0, end: 0.2)
          .scale(
            duration: _turnOnDuration,
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

  Future<void> _onTap() async {
    Feedback.forTap(context);
    await runCommand(
      context: context,
      action: () => ref.read(streetLampStoreProvider.notifier).toggle(widget.id),
      onLoadingStart: () => setState(() {
        _action = widget.isLit ? FlameAction.turningOff : FlameAction.turningOn;
      }),
      onLoadingEnd: () => setState(() => _action = FlameAction.idle),
    );
  }

  // _buildFlameDecoration() inchangé
}
```

> **Note sur `_onTap`** : il utilise `runCommand` (helper issu de `command_pattern_consolidation.md`) et `streetLampStoreProvider` (issu de `normalized_entity_store.md`). Si cette refacto est faite **avant** les deux autres, remplacer temporairement par :
>
> ```dart
> Future<void> _onTap() async {
>   Feedback.forTap(context);
>   setState(() {
>     _action = widget.isLit ? FlameAction.turningOff : FlameAction.turningOn;
>   });
>   try {
>     await ref.read(lampDetailsProvider(lampId: widget.id).notifier).toggle();
>   } catch (e, t) {
>     handleCommandError(context, e, t);
>   } finally {
>     if (mounted) setState(() => _action = FlameAction.idle);
>   }
> }
> ```
>
> Et quand `runCommand` et le store arriveront, le `_onTap` se simplifie en version du snippet principal. La refacto d'état reste valable dans les deux cas.

## Ce que ça élimine

| Avant | Après |
|-------|-------|
| 3 booléens (`_isLoading`, `_isTurningOn`, `_isTurningOff`) mutuellement exclusifs | 1 enum `_action` à 3 valeurs |
| 16 états combinatoires possibles dont 12 n'ont aucun sens | 3 états + `widget.isLit` (data) — états invalides inexprimables |
| `if (_isLoading || widget.isLit)` opaque | `showFlame = widget.isLit \|\| isTransitioning` — intention lisible |
| 3 `if` en cascade dans `_getAnimatedContainer` avec fallback implicite | `switch (_action)` exhaustif — le compilateur vérifie les 3 cas |
| `_isTurningOff = _isTurningOn = false` dans `finally` (2 writes couplés) | `_action = FlameAction.idle` (1 write) |
| Magic numbers `2000`, `5000`, `20000` | `_turnOnDuration`, `_turnOffDuration`, `_pulseDuration` — nommés |

## Compatibilité avec les autres improvements

- **`command_pattern_consolidation.md` (Partie 1 — `runCommand`)** : le `try/catch/finally` du `_onTap` devient `runCommand`. Cette refacto et celle-là sont **complémentaires** — faire l'état d'abord (ce doc), puis `runCommand` pour finir de nettoyer `_onTap`.
- **`normalized_entity_store.md` (Partie 2 — store)** : quand le store arrive, `lampDetailsProvider(lampId: ...)` est remplacé par `streetLampStoreProvider.notifier`. Côté `LitLampWidget`, seul l'appel dans `_onTap` change. L'état local (`_action`) reste identique : il encode la transition visuelle, pas l'état de la donnée.
- **`mutation_v3.md` (post-v3)** : `runCommand` disparaît au profit de `mutation.run(...)`. `_action` pourrait alors être dérivé d'un `ref.watch(mutation)` au lieu d'un `setState` local — mais c'est une décision v3, pas maintenant. L'enum survit à toutes ces étapes.

## Checklist d'exécution

1. Ajouter l'enum `FlameAction { idle, turningOn, turningOff }` en haut du fichier.
2. Remplacer les 3 champs `_isLoading`, `_isTurningOn`, `_isTurningOff` par `FlameAction _action = FlameAction.idle`.
3. Ajouter les 3 constantes de durée (`_turnOnDuration`, `_turnOffDuration`, `_pulseDuration`).
4. Refactorer `build` pour utiliser `isTransitioning` et `showFlame`.
5. Refactorer `_getAnimatedContainer` en `_buildFlame` avec `switch (_action)`.
6. Refactorer `_onTap` (version transitoire avec try/catch local tant que `runCommand` n'est pas là, ou version finale si fait après).
7. Lancer `flutter analyze` et tester à la main les 3 chemins :
   - tap sur lamp éteinte (turningOn → lit)
   - tap sur lamp allumée (turningOff → off)
   - tap avec serveur en échec (roll back visuel à l'état stable initial)
8. Commit.

## Est-ce que ça vaut le coup ?

Oui, et pour trois raisons :

1. **Lisibilité immédiate.** Le `build` devient lisible en une passe, le `switch` rend les 3 animations nommées et exhaustives.
2. **Sécurité statique.** Plus aucun état invalide possible. Ajouter une 4ᵉ animation plus tard (par exemple `flicker` en cas d'erreur) se fait en ajoutant une valeur à l'enum + une branche au switch — le compilateur force la complétude.
3. **Pérenne.** L'enum survit à `runCommand` (Partie 1), au store normalisé (Partie 2) et à `Mutation` v3. Il n'est pas jetable. Seule la source de l'état change (local `setState` → `ref.watch(mutation)` plus tard), pas sa forme.
