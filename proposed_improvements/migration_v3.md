# Migration vers Riverpod v3

> **Versions cibles** (vérifiées sur pub.dev au 2026-07-15) :
> - `flutter_riverpod` : **3.3.2** (runtime, reste en 3.x — pas de v4 runtime)
> - `riverpod_annotation` : **4.0.3** (codegen annotation)
> - `riverpod_generator` : **4.0.4** (codegen generator)
>
> Le runtime et les outils de codegen ont un versioning découplé : `flutter_riverpod` reste en 3.x, mais `riverpod_annotation`/`riverpod_generator` ont sauté à 4.0. C'est juste un bump majeur des outils, aligné avec riverpod 3.3.2. Ne pas chercher `flutter_riverpod: ^4.0.0` — il n'existe pas.

## Objectif

Faire compiler et tourner falotier sur Riverpod 3.3.2 + generator 4.0.4, sans changement fonctionnel. C'est le prérequis avant d'envisager `Mutation` (voir `mutation_v3.md`) — Mutation est expérimental et vit dans le runtime 3.x.

La migration est mécanique pour l'essentiel : bumper les deps, lancer `dart fix`, régénérer le code, désactiver le retry sur le mock error. Les families **ne sont pas** un refactor manuel en codegen (correction d'une erreur dans `mutation_v3.md`).

## 1. `pubspec.yaml` — bumper les deps ensemble

Ne jamais mélanger 2.x et 3.x, ça ne résout pas.

### Before — `pubspec.yaml:36-37,54`

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  riverpod_generator: ^2.4.3
```

### After

```yaml
dependencies:
  flutter_riverpod: ^3.3.2
  riverpod_annotation: ^4.0.3

dev_dependencies:
  riverpod_generator: ^4.0.4
  riverpod_lint: ^3.3.2     # nouveau — active les `dart fix` auto
  custom_lint: ^0.8.0       # requis par riverpod_lint
  build_runner: ^2.4.12     # déjà présent
```

```bash
flutter pub get
flutter pub deps | grep riverpod   # vérifier que tout est aligné (pas de 2.x résiduel)
```

## 2. `dart fix` — renommer les `*Ref` en `Ref`

`riverpod_lint` fournit les règles `dart fix` qui font le rename mécanique sur tous les fichiers d'un coup. À lancer **avant** la régénération.

```bash
dart fix --dry-run     # preview
dart fix --apply       # applique
```

### Before — `lib/domain/city_zones/providers.dart:12,18`

Tes deux providers fonctionnels ont des `*Ref` typés en signature (le codegen v2 les générait) :

```dart
@Riverpod(keepAlive: true)
Future<IList<CityZone>> availableZones(AvailableZonesRef ref) {
  final repository = ref.watch(cityZoneRemoteRepositoryProvider);
  return repository.getAvailableZones();
}

@Riverpod(keepAlive: true)
Future<IList<Street>> streets(StreetsRef ref, {required CityZone zone}) {
  final repository = ref.watch(cityZoneRemoteRepositoryProvider);
  return repository.getZoneStreets(zone);
}
```

### After — `Ref` unifié

```dart
@Riverpod(keepAlive: true)
Future<IList<CityZone>> availableZones(Ref ref) {
  final repository = ref.watch(cityZoneRemoteRepositoryProvider);
  return repository.getAvailableZones();
}

@Riverpod(keepAlive: true)
Future<IList<Street>> streets(Ref ref, {required CityZone zone}) {
  final repository = ref.watch(cityZoneRemoteRepositoryProvider);
  return repository.getZoneStreets(zone);
}
```

Les class-based (`ZoneStreetLamps`, `StreetLampState`, `AvailableStreets`, `SelectedZone`, `LampList`, `LampDetails`) n'ont pas de `*Ref` en signature → `dart fix` ne les touche pas, le codegen s'en occupe.

## 3. Régénérer le code — le `.g.dart` change de forme

```bash
dart run build_runner build --delete-conflicting-outputs
```

Ta source `providers.dart` reste **identique** pour les families (toujours `build({required CityZone zone})`). C'est le `.g.dart` qui change en dessous. Ne pas éditer la source des families à la main — c'était l'erreur de `mutation_v3.md` qui montrait `ZoneStreetLamps(this.zone)` + `build()`. Cette migration manuelle ne s'applique qu'au hand-written, pas au codegen. Le mainteneur le confirme dans le RFC #4218 :

> Code generation is not impacted and we'd still be defining parameters on `Notifier.build` instead.

### Before — `lib/domain/street_lamps/providers.g.dart` (codegen v2)

Le codegen v2 génère des mixins `*Ref`, des `BuildlessAsyncNotifier` avec `late final` arg, des préfixes `AutoDispose` :

```dart
abstract class _$ZoneStreetLamps
    extends BuildlessAsyncNotifier<IList<StreetLamp>> {
  late final CityZone zone;

  FutureOr<IList<StreetLamp>> build({
    required CityZone zone,
  });
}

// ...
mixin ZoneStreetLampsRef on AsyncNotifierProviderRef<IList<StreetLamp>> {
  CityZone get zone;
}

class _ZoneStreetLampsProviderElement
    extends AsyncNotifierProviderElement<ZoneStreetLamps, IList<StreetLamp>>
    with ZoneStreetLampsRef {
  _ZoneStreetLampsProviderElement(super.provider);

  @override
  CityZone get zone => (origin as ZoneStreetLampsProvider).zone;
}
```

Et pour `LampDetails` (autoDispose), `street_lamp_details/providers.g.dart:33` :

```dart
abstract class _$LampDetails
    extends BuildlessAutoDisposeAsyncNotifier<StreetLamp> {
  late final String lampId;
  // ...
}

class LampDetailsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<LampDetails, StreetLamp> {
  // ...
}

mixin LampDetailsRef on AutoDisposeAsyncNotifierProviderRef<StreetLamp> {
  String get lampId;
}
```

### After — codegen 4.0.4

Le nouveau `.g.dart` :
- **supprime les mixins `*Ref on *ProviderRef`** (plus de `ZoneStreetLampsRef`, `StreetLampStateRef`, `StreetsRef`, `AvailableStreetsRef`, `LampDetailsRef`)
- **supprime `BuildlessAsyncNotifier` / `BuildlessAutoDisposeAsyncNotifier`** au profit des nouvelles base classes unifiées
- **retire les préfixes `AutoDispose`** des noms générés (`AutoDisposeAsyncNotifierProviderImpl` → `AsyncNotifierProviderImpl`, l'autoDispose devient un modificateur)
- **change la shape des `*Family`/`*Provider`** générés
- **les providers générés ne sont plus `const`** (changelog generator 4.0.0)

Ta source `providers.dart` n'a pas bougé — seuls les `.g.dart` sont réécrits. Si `build_runner` râle sur un fichier, c'est le seul endroit où tu touches à la main.

## 4. Désactiver le retry sur le mock error — piège runtime

C'est le changement runtime le plus concret pour falotier. En v3, les providers qui failent sont retry automatiquement avec backoff exponentiel (200ms → 6.4s, retry infini jusqu'à succès ou dispose).

Ton `getList` à `exceptionProbability: 1` (`lib/domain/street_lamps/impl/remote_repository_mock.dart:66`) échoue **toujours** :

```dart
@override
Future<IList<StreetLamp>> getList(CityZone zone) async {
  _log.i('getList( $zone )');
  await _emulator.makeRemoteCallWith(exceptionProbability: 1);  // ← toujours erreur
  return _zoneLamps![zone]!.values.toIList();
}
```

En v2 : `AsyncError` affiché par `AsyncValueWidget` → l'utilisateur voit l'état d'erreur (c'est le scénario demo du README).
En v3 sans config : retry indéfini, l'erreur ne s'affiche jamais, le spinner ou un état intermédiaire persiste. **La demo casse.**

### Before — `lib/app.dart:21` (pas de config retry, n'existe pas en v2)

```dart
return ProviderScope(
  child: AppTheme(
    data: themeData,
    child: MaterialApp.router(...),
  ),
);
```

### After — désactiver le retry globalement (PoC)

```dart
return ProviderScope(
  retry: (_, __) => null,   // PoC : on veut voir l'erreur, pas retry
  child: AppTheme(
    data: themeData,
    child: MaterialApp.router(...),
  ),
);
```

### Alternative — per-provider sur `ZoneStreetLamps`

Si tu veux garder le retry pour les vrais providers et ne l'exclure que sur le mock :

```dart
@Riverpod(keepAlive: true, retry: (_, __) => null)
class ZoneStreetLamps extends _$ZoneStreetLamps { ... }
```

Vu que tout est mock en falotier, le global est plus simple.

## 5. `keepAlive` + pause hors vue — à valider au runtime

V3 met en pause les providers hors vue par défaut (`TickerMode`-based). Ton `keepAlive: true` les garde en vie, mais **en pause** — c'est subtilement différent de « vivants et qui notifient ».

C'est le scénario que tu m'as décrit plus tôt : tu pop la `StreetLampsScreen`, tu y reviens, tu ne veux pas re-fetcher. En v2 `keepAlive` suffit. En v3 il faut valider que le cache de session marche toujours.

### Before — `lib/domain/street_lamps/providers.dart:13`

```dart
@Riverpod(keepAlive: true)
class ZoneStreetLamps extends _$ZoneStreetLamps { ... }
```

### After — probablement inchangé, mais à tester

Garde `keepAlive: true`. Si au runtime tu constates un re-fetch au retour sur l'écran, deux options :

**Option A — `TickerMode` autour du consumer** :

```dart
TickerMode(
  enabled: true,
  child: Consumer(
    builder: (context, ref, child) {
      final asyncValue = ref.watch(zoneStreetLampsProvider(zone: zone));
      // ...
    },
  ),
)
```

**Option B — `ref.listen` non-pausable** au lieu de `ref.watch` pour les caches long-terme. Plus intrusif.

À valider en premier par test manuel : lance l'app, charge la liste, pop l'écran, reviens. Si la liste réapparaît sans spinner, `keepAlive` suffit. Sinon, Option A.

## 6. Ce qui ne change pas (vérifié dans ton code)

Ces breaking changes v3 te touchent théoriquement mais pas en pratique :

- **`ProviderException` wrapping** : tu affiches les erreurs via `AsyncValue` (`AsyncValueWidget`), pas via `try/catch` sur `.future`. Aucun `on ItemNotFoundException catch` sur un `ref.read(...future)`. → aucun changement. (Si tu catchais l'erreur typée, il faudrait `on ProviderException catch (e) { if (e.exception is ItemNotFoundException) ... }`.)
- **`==` filtering** : tes entités sont `freezed` (value equality) + `IList` (value equality). Après add/remove/toggle le contenu diffère donc `==` est false → notify. Tu overridais déjà `updateShouldNotify` sur `SelectedZone` (`lib/presentation/home/providers.dart:30`). → OK, juste à vérifier qu'aucun update silencieux ne se perd au runtime.
- **`AsyncValue.valueOrNull` supprimé** : tu n'utilises pas `valueOrNull`. Tu fais `state.value!` gardé par `state.hasValue` (`StreetLampState.updateLight:70`). En v3 `.value` renvoie `null` sur erreur au lieu de throw — ton guard `hasValue` te protège. → OK.
- **Legacy providers** : tu n'utilises ni `StateProvider`, ni `StateNotifierProvider`, ni `ChangeNotifierProvider`. → pas d'import `package:flutter_riverpod/legacy.dart` à ajouter.
- **`ProviderObserver` interface** : tu n'as pas d'observer. → pas concerné.

## 7. Analyze + tests

```bash
flutter analyze
flutter test
```

Ton `test/widget_test.dart` est quasi vide — c'est le moment idéal pour ajouter des tests provider sur les mutations. V3 apporte `ProviderContainer.test()` qui auto-dispose après le test :

```dart
void main() {
  test('ZoneStreetLamps emits sorted list after build', () async {
    final container = ProviderContainer.test();
    final list = await container.read(
      zoneStreetLampsProvider(zone: CityZone('1', 'Paris')).future,
    );
    expect(list, isNotEmpty);
    expect(list, isSortedBy(streetLampComparator));
  });
}
```

## Checklist ordonnée

1. `git stash` ou commit — avoir un diff propre
2. Bumper `pubspec.yaml` (flutter_riverpod 3.3.2, annotation 4.0.3, generator 4.0.4, + riverpod_lint + custom_lint)
3. `flutter pub get` + vérifier `flutter pub deps | grep riverpod`
4. `dart fix --dry-run` puis `dart fix --apply` — rename `*Ref`→`Ref` sur les 2 providers fonctionnels
5. `dart run build_runner build --delete-conflicting-outputs` — régénérer les `.g.dart`
6. Désactiver le retry : `retry: (_, __) => null` sur le `ProviderScope` dans `lib/app.dart`
7. `flutter analyze` — doit passer à zéro
8. Test runtime : charge la liste, pop l'écran, reviens → valider `keepAlive`+pause (étape 5 du doc)
9. `flutter test` — ajouter au moins un test provider sur `ZoneStreetLamps`
10. Commit

## Résumé de l'effort

| Étape | Travail | Automatisable |
|---|---|---|
| Bumper pubspec | 4 lignes | manuel |
| `dart fix --apply` | rename `*Ref`→`Ref` (2 fns) | auto |
| `build_runner build` | régénérer `.g.dart` | auto |
| Désactiver retry | 1 ligne (global) | manuel |
| Vérifier keepAlive+pause | test runtime | manuel |
| analyze + tests | validation | manuel |

Demi-journée, dont la majeure partie mécanique. Les families ne sont **pas** un refactor manuel pour toi — c'était l'erreur de `mutation_v3.md`. La seule vraie surveillance runtime est le combo `keepAlive` + pause hors vue (étape 5).

## Une fois la migration mécanique faite

Le runtime 3.3.2 débloque `Mutation` (voir `mutation_v3.md`) et l'offline persistence (expérimental). Mais l'ordre recommandé reste :

1. **Cette migration mécanique** — faire compiler et tourner sur v3.
2. **Normalized store** (voir `normalized_entity_store.md`) — indépendant de v3, plus gros gain structurel, à faire avant ou après la migration mécanique.
3. **Mutation** — seulement si tu veux formaliser l'état d'action, sur un flow simple (le remove).

Ne pas inverser 1 et 2 : migrer puis refondre le store, c'est refondre sur du code fraîchement migré. Mais le store peut se faire en v2 d'abord, puis migrer ensuite — les deux ordres sont défendables. L'important est de ne pas commencer par Mutation sur du v2.
