# Migration vers Riverpod v3 — **sans code generation**

> **Alternative à `migration_v3.md`.** Ce doc décrit la migration en **abandonnant le codegen** (`@riverpod`, `riverpod_generator`, les `.g.dart`) au profit du hand-written. C'est une option légitime en v3.3.2 grâce à la simplification de l'API hand-written (un seul `Ref`, `FamilyNotifier` supprimé, modificateurs `.family`/`.autoDispose`).
>
> **Versions cibles** (vérifiées sur pub.dev au 2026-07-15) :
> - `flutter_riverpod` : **3.3.2**
> - `riverpod_lint` : **3.3.2** (gardé — fournit les `dart fix` et les lints, sans codegen)
> - `custom_lint` : **^0.8.0** (requis par riverpod_lint)
>
> **On retire** : `riverpod_annotation`, `riverpod_generator`, `build_runner` (pour le code Riverpod — freezed garde le sien).

## Ce que v3 a réellement livré vs ce qui est encore RFC

Ta mémoire est partiellement juste. Deux niveaux à ne pas confondre :

1. **Livré dans 3.3.2 (ce qu'on utilise ici)** : `Ref` unifié, `FamilyNotifier`/`AutoDisposeNotifier` supprimés → un seul `Notifier`/`AsyncNotifier` avec args en **constructeur** + modificateurs `.family`/`.autoDispose`/`isAutoDispose: false`. Le hand-written devient viable et propre.

2. **Encore RFC #4008 (open, 153 👍, pas livré)** : la syntaxe radicale — un seul `Provider` class, plus de notion de notifier, `ref.invoke(provider.method())`, `args` record, `Scope`. Cible probablement 4.0. **On ne peut pas migrer vers ça, ça n'existe pas encore.** Ce doc n'utilise pas cette syntaxe.

Donc on passe de `@riverpod` + `.g.dart` → hand-written `Notifier`/`AsyncNotifier` + `NotifierProvider`/`AsyncNotifierProvider` avec modificateurs. C'est la vraie API 3.3.2.

## Le tradeoff à savoir avant de choisir

**Family sans codegen = un seul argument positionnel.** Pas de named, pas d'optional, pas de default. C'est la limitation que le RFC #4008 appelle explicitement (« family's syntax without code-generation is bad »). Le codegen te donne les named args gratuitement ; le hand-written non.

Pour falotier c'est OK : tes 5 families (`ZoneStreetLamps`, `StreetLampState`, `AvailableStreets`, `streets`, `LampDetails`) prennent toutes **un seul arg**. Mais il faudra transformer les `{required CityZone zone}` named en arg positionnel, et les call sites `provider(zone: x)` → `provider(x)`.

## 1. `pubspec.yaml` — retirer le codegen Riverpod

### Before

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  riverpod_generator: ^2.4.3
  build_runner: ^2.4.12
```

### After

```yaml
dependencies:
  flutter_riverpod: ^3.3.2

dev_dependencies:
  riverpod_lint: ^3.3.2       # lints + dart fix, SANS codegen
  custom_lint: ^0.8.0
  build_runner: ^2.4.12       # gardé pour freezed uniquement
```

On retire `riverpod_annotation` et `riverpod_generator`. `build_runner` reste parce que `freezed` en a encore besoin pour les entités (`street_lamp.freezed.dart`, etc.) — c'est orthogonal à Riverpod.

```bash
flutter pub get
flutter pub deps | grep riverpod   # ne doit plus montrer annotation/generator
```

## 2. Repository providers — déjà hand-written, juste retrait du `Provider` typedef

Tes repository providers sont déjà quasi hand-written (pas annotés `@riverpod`), ils utilisent `Provider` directement. Ils marchent en v3 à l'identique — `Provider` n'a pas bougé pour ce cas simple.

### Before — `lib/domain/street_lamps/interfaces.dart:10`

```dart
import 'impl/remote_repository_mock.dart';
import 'street_lamp.dart';

final streetLampRemoteRepositoryProvider = Provider<StreetLampRemoteRepository>(
    (ref) => ref.watch(streetLampRemoteRepositoryMockProvider));
```

### After — inchangé

```dart
final streetLampRemoteRepositoryProvider = Provider<StreetLampRemoteRepository>(
    (ref) => ref.watch(streetLampRemoteRepositoryMockProvider));
```

Idem pour `cityZoneRemoteRepositoryProvider`, `streetLampRemoteRepositoryMockProvider`, `cityZoneRemoteRepositoryMockProvider`. Rien à toucher. La seule chose : supprimer les `part 'providers.g.dart';` partout.

## 3. Functional providers → `FutureProvider.family` (avec la limite named-arg)

Tes deux providers fonctionnels ont des `*Ref` typés (générés par le codegen v2) et un **named arg** pour la family.

### Before — `lib/domain/city_zones/providers.dart:12,18`

```dart
part 'providers.g.dart';

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

### After — hand-written, arg positionnel

```dart
// plus de part 'providers.g.dart';

final availableZonesProvider =
    FutureProvider<IList<CityZone>>((ref) {
  final repository = ref.watch(cityZoneRemoteRepositoryProvider);
  return repository.getAvailableZones();
}, isAutoDispose: false);

final streetsProvider =
    FutureProvider.family<IList<Street>, CityZone>((ref, zone) {
  final repository = ref.watch(cityZoneRemoteRepositoryProvider);
  return repository.getZoneStreets(zone);
}, isAutoDispose: false);
```

**Changements** :
- `AvailableZonesRef`/`StreetsRef` → `Ref` implicite (le callback prend `ref` non typé)
- `{required CityZone zone}` → `zone` positionnel (limite hand-written)
- `keepAlive: true` → `isAutoDispose: false` (le modificateur v3)
- Call sites : `streetsProvider(zone: zone)` → `streetsProvider(zone)` partout (`availableStreetsProvider` dans `city_zones/providers.dart:33`, etc.)

## 4. Class-based AsyncNotifier families → constructeur + `.family`

C'est le gros du travail. Tes 4 notifiers family passent de `build({required X arg})` à un constructeur + `build()` sans arg.

### Before — `lib/domain/street_lamps/providers.dart:14`

```dart
part 'providers.g.dart';

@Riverpod(keepAlive: true)
class ZoneStreetLamps extends _$ZoneStreetLamps {
  static final _log = LoggerFactory.logger('ZoneStreetLampsProvider');

  @override
  Future<IList<StreetLamp>> build({required CityZone zone}) async {
    final repository = ref.watch(streetLampRemoteRepositoryProvider);
    final lamps = await repository.getList(zone);
    return lamps.sort(streetLampComparator);
  }

  Future addOrUpdate(StreetLamp streetLamp) async { ... }
  Future remove(StreetLamp streetLamp) async { ... }
}
```

### After — `AsyncNotifier` + constructeur + `AsyncNotifierProvider.family`

```dart
// plus de part 'providers.g.dart';

class ZoneStreetLamps extends AsyncNotifier<IList<StreetLamp>> {
  ZoneStreetLamps(this.zone);
  final CityZone zone;

  static final _log = LoggerFactory.logger('ZoneStreetLampsProvider');

  @override
  Future<IList<StreetLamp>> build() async {
    final repository = ref.watch(streetLampRemoteRepositoryProvider);
    final lamps = await repository.getList(zone);
    return lamps.sort(streetLampComparator);
  }

  Future addOrUpdate(StreetLamp streetLamp) async { ... }  // inchangé
  Future remove(StreetLamp streetLamp) async { ... }       // inchangé
}

final zoneStreetLampsProvider =
    AsyncNotifierProvider.family<ZoneStreetLamps, IList<StreetLamp>, CityZone>(
  ZoneStreetLamps.new,
  isAutoDispose: false,
);
```

**Changements** :
- `extends _$ZoneStreetLamps` (généré) → `extends AsyncNotifier<IList<StreetLamp>>` (réel)
- `build({required CityZone zone})` → `ZoneStreetLamps(this.zone); final CityZone zone;` + `build()`
- `@Riverpod(keepAlive: true)` → déclaration explicite `AsyncNotifierProvider.family<...>(X.new, isAutoDispose: false)`
- Call sites : `zoneStreetLampsProvider(zone: x)` → `zoneStreetLampsProvider(x)`

### Idem pour les 3 autres notifiers family

`StreetLampState` (`lib/domain/street_lamps/providers.dart:58`) :

```dart
class StreetLampState extends AsyncNotifier<StreetLamp> {
  StreetLampState(this.id);
  final String id;

  static final _log = LoggerFactory.logger('StreetLampStateProvider');

  @override
  Future<StreetLamp> build() {
    return ref.watch(streetLampRemoteRepositoryProvider).get(id);
  }

  Future updateLight(bool isLit) async { ... }  // inchangé, utilise `id` au lieu de l'arg
}

final streetLampStateProvider =
    AsyncNotifierProvider.family<StreetLampState, StreetLamp, String>(
  StreetLampState.new,
  isAutoDispose: false,
);
```

`AvailableStreets` (`lib/domain/city_zones/providers.dart:24`) — a une méthode `reload()` :

```dart
class AvailableStreets extends AsyncNotifier<IList<Street>> {
  AvailableStreets(this.zone);
  final CityZone zone;

  static final _log = LoggerFactory.logger('AvailableStreetsProvider');

  @override
  Future<IList<Street>> build() async {
    final streetsWithLamp =
        await ref.watch(zoneStreetLampsProvider(zone).future);
    final allStreets = await ref.watch(streetsProvider(zone).future);
    return allStreets
        .asSet()
        .difference(streetsWithLamp.map((l) => l.street).asSet())
        .toIList()
        .sort(streetComparator);
  }

  reload() {
    ref.invalidate(zoneStreetLampsProvider(zone));
    ref.invalidate(streetsProvider(zone));
  }
}

final availableStreetsProvider =
    AsyncNotifierProvider.family<AvailableStreets, IList<Street>, CityZone>(
  AvailableStreets.new,
  isAutoDispose: false,
);
```

`LampDetails` (`lib/presentation/street_lamp_details/providers.dart:11`) — **autoDispose** :

```dart
class LampDetails extends AsyncNotifier<StreetLamp> {
  LampDetails(this.lampId);
  final String lampId;

  static final _log = LoggerFactory.logger('LampDetailsProvider');

  @override
  Future<StreetLamp> build() {
    return ref.watch(streetLampStateProvider(lampId).future);
  }

  Future toggle() async { ... }  // inchangé, utilise `lampId`
}

final lampDetailsProvider =
    AsyncNotifierProvider.family<LampDetails, StreetLamp, String>(
  LampDetails.new,
  // autoDispose par défaut, pas de flag
);
```

Note : `LampDetails` était `@riverpod` (autoDispose par défaut en v2 codegen). En hand-written v3, `AsyncNotifierProvider.family` est autoDispose par défaut — donc pas de flag à mettre. C'est l'inverse des autres où tu veux `isAutoDispose: false`.

## 5. Class-based AsyncNotifier non-family → `AsyncNotifierProvider`

`DomainInitializer` (`lib/domain/domain_initializer.dart:10`), `SelectedZone` (`lib/presentation/home/providers.dart:13`), `LampList` (`lib/presentation/home/providers.dart:56`) — keepAlive, pas de family.

### Before — `lib/domain/domain_initializer.dart:10`

```dart
part 'domain_initializer.g.dart';

@Riverpod(keepAlive: true)
class DomainInitializer extends _$DomainInitializer {
  static final _log = LoggerFactory.logger('DomainInitializerProvider');

  @override
  Future<bool> build() async { ... }

  reload() { ... }
}
```

### After

```dart
class DomainInitializer extends AsyncNotifier<bool> {
  static final _log = LoggerFactory.logger('DomainInitializerProvider');

  @override
  Future<bool> build() async { ... }  // inchangé

  reload() { ... }  // inchangé
}

final domainInitializerProvider =
    AsyncNotifierProvider<DomainInitializer, bool>(
  DomainInitializer.new,
  isAutoDispose: false,
);
```

Idem pour `SelectedZone` (avec son `updateShouldNotify` override à garder) et `LampList` (avec son champ `selectedZone` et ses méthodes `refresh`/`reload`/`addOrUpdate`/`remove` — tout inchangé côté corps, juste la déclaration qui change).

## 6. Désactiver le retry sur le mock error — même piège qu'avec codegen

Identique à `migration_v3.md` étape 4. Ton `getList` à `exceptionProbability: 1` (`street_lamps/impl/remote_repository_mock.dart:66`) échoue toujours → retry indéfini en v3.

### Before — `lib/app.dart:21`

```dart
return ProviderScope(
  child: AppTheme(...),
);
```

### After

```dart
return ProviderScope(
  retry: (_, __) => null,   // PoC : on veut voir l'erreur
  child: AppTheme(...),
);
```

Ou per-provider :

```dart
final zoneStreetLampsProvider =
    AsyncNotifierProvider.family<ZoneStreetLamps, IList<StreetLamp>, CityZone>(
  ZoneStreetLamps.new,
  isAutoDispose: false,
  retry: (_, __) => null,
);
```

## 7. `keepAlive` → `isAutoDispose: false` + pause hors vue

Même surveillance runtime que `migration_v3.md` étape 5. V3 met en pause les providers hors vue. Tes `isAutoDispose: false` les garde en vie mais *en pause*. À valider au runtime : pop l'écran, reviens, vérifie que la liste ne re-fetch pas.

Si ça re-fetch, `TickerMode(enabled: true, child: Consumer(...))` autour du consumer. Voir `migration_v3.md` pour le détail.

## 8. Ce qui ne change pas (vérifié dans ton code)

Identique à `migration_v3.md` étape 6 — ces breaking changes v3 te touchent théoriquement mais pas en pratique :

- **`ProviderException` wrapping** : tu affiches via `AsyncValue`, pas de `try/catch` sur `.future` typé. → OK.
- **`==` filtering** : entités `freezed` + `IList`, value equality. → OK, juste à vérifier au runtime.
- **`AsyncValue.valueOrNull` supprimé** : tu fais `state.value!` gardé par `hasValue`. → OK (en v3 `.value` renvoie `null` sur erreur, ton guard te protège).
- **Legacy providers** : tu n'utilises ni `StateProvider`, ni `StateNotifierProvider`, ni `ChangeNotifierProvider`. → pas d'import `legacy.dart`.
- **`ProviderObserver`** : tu n'en as pas. → pas concerné.

## 9. Nettoyage final

```bash
# supprimer tous les .g.dart Riverpod (PAS les .freezed.dart)
rm lib/domain/street_lamps/providers.g.dart
rm lib/domain/city_zones/providers.g.dart
rm lib/domain/domain_initializer.g.dart
rm lib/presentation/home/providers.g.dart
rm lib/presentation/street_lamp_details/providers.g.dart
rm lib/routes.g.dart          # go_router_builder — voir note ci-dessous

# retirer tous les `part 'xxx.g.dart';` dans les sources Riverpod
# (grep pour les repérer)
grep -rn "part '.*\.g\.dart';" lib/

# regenerate freezed + go_router (qui restent en codegen)
dart run build_runner build --delete-conflicting-outputs

flutter analyze
flutter test
```

**Note `go_router_builder`** : `lib/routes.dart` utilise `@TypedGoRoute` + `part 'routes.g.dart'`. C'est du codegen go_router, pas Riverpod — tu peux le garder. Si tu veux aller full no-codegen, il faudra aussi réécrire `routes.dart` en `GoRouter` hand-written, mais c'est orthogonal et je ne le ferais pas dans cette migration.

## Checklist ordonnée

1. `git stash` ou commit
2. `pubspec.yaml` : `flutter_riverpod ^3.3.2`, retirer `riverpod_annotation`/`riverpod_generator`, garder `riverpod_lint`/`custom_lint`/`build_runner`
3. `flutter pub get` + vérifier `flutter pub deps | grep riverpod`
4. `dart fix --dry-run` puis `dart fix --apply` — rename les `*Ref` résiduels (limité, la plupart partent avec la réécriture)
5. Réécrire les 2 functional providers (`availableZones`, `streets`) en `FutureProvider`/`FutureProvider.family`
6. Réécrire les 5 notifiers family (`ZoneStreetLamps`, `StreetLampState`, `AvailableStreets`, `LampDetails`) en `AsyncNotifier` + constructeur + `AsyncNotifierProvider.family`
7. Réécrire les 3 notifiers non-family (`DomainInitializer`, `SelectedZone`, `LampList`) en `AsyncNotifierProvider`
8. Mettre à jour tous les call sites : `provider(zone: x)` → `provider(x)`, `provider(id: x)` → `provider(x)`, `provider(lampId: x)` → `provider(x)`
9. Retirer les `part 'xxx.g.dart';` et supprimer les `.g.dart` Riverpod
10. Désactiver le retry : `retry: (_, __) => null` sur le `ProviderScope`
11. `dart run build_runner build --delete-conflicting-outputs` (pour freezed + go_router restants)
12. `flutter analyze` — doit passer à zéro
13. Test runtime : pop/return écran → valider `isAutoDispose: false` + pause
14. `flutter test` — ajouter un test provider (`ProviderContainer.test()`)
15. Commit

## Résumé de l'effort

| Étape | Travail | Automatisable |
|---|---|---|
| pubspec | retirer 2 deps | manuel |
| `dart fix` | rename `*Ref` résiduels | auto |
| Functional providers (2) | réécrire en `FutureProvider.family` | manuel |
| Notifiers family (5) | constructeur + `.family` | manuel |
| Notifiers non-family (3) | `AsyncNotifierProvider` | manuel |
| Call sites | named → positionnel (~10 sites) | manuel |
| Supprimer `.g.dart` Riverpod | rm + retirer `part` | manuel |
| Désactiver retry | 1 ligne | manuel |
| analyze + tests | validation | manuel |

**Une journée** (vs demi-journée pour la migration codegen). Le surcoût vs `migration_v3.md` vient de la réécriture manuelle des 10 providers + les call sites. Le bénéfice : plus de `.g.dart` Riverpod à régénérer, plus de `build_runner` pour Riverpod, source plus directe à lire.

## Codegen vs hand-written — comparison

| Critère | Codegen (`migration_v3.md`) | Hand-written (ce doc) |
|---|---|---|
| Dépendances | + annotation + generator | juste flutter_riverpod + lint |
| `.g.dart` Riverpod | oui, à régénérer | aucun |
| `build_runner` pour Riverpod | oui | non (juste freezed/go_router) |
| Named/optional/default family args | oui | **non, un seul positionnel** |
| Boilerplate par provider | faible (`@riverpod` + `part`) | moyen (constructeur + déclaration provider) |
| Vitesse de build | ralentie par codegen | plus rapide |
| Readability source | dépend de l'IDE pour sauter les `.g` | direct |
| Effort migration | demi-journée | une journée |
| Futur RFC #4008 (single `Provider` class) | le codegen s'adaptera | le hand-written devra réécrire |

## Recommandation

**Pour falotier : garde le codegen (`migration_v3.md`).** Reasons :

1. Tu perds les named args sur les families — pas un problème aujourd'hui (1 arg chacun) mais une régression de DX.
2. La réécriture manuelle de 10 providers + ~10 call sites est plus longue que `dart fix` + `build_runner`.
3. Le codegen v3.3.2 est stable et mature ; le hand-written reste une option mais pas un avantage net sur un PoC déjà en codegen.
4. Si tu veux later adopter le RFC #4008 (quand il sortira), le codegen s'adaptera probablement mieux que du hand-written à réécrire.

**Garde ce doc si** : tu veux te débarrasser du codegen pour accélérer les builds, ou tu veux une source plus directe à lire sans `.g.dart`, ou tu anticipes une migration vers une codebase sans codegen. C'est un choix défendable — juste plus coûteux maintenant.

L'ordre des trois docs reste :
1. `migration_v3.md` (codegen) **ou** `migration_v3_no_codegen.md` (ce doc) — choisis l'un.
2. `normalized_entity_store.md` — indépendant.
3. `mutation_v3.md` — après, sur un flow simple.
