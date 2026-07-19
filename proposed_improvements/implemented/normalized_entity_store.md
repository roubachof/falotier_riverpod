# Single source of truth pour `StreetLamp` : le normalized entity store

## Problème

Aujourd'hui, une même entité `StreetLamp` vit dans **deux providers distincts** :

- `ZoneStreetLamps(zone:)` → `IList<StreetLamp>` (la liste, `lib/domain/street_lamps/providers.dart`)
- `StreetLampState(id:)` → `StreetLamp` (le détail, même fichier)

La cohérence entre les deux est assurée **manuellement** dans `StreetLampState.updateLight` :

```dart
Future updateLight(bool isLit) async {
  ...
  final updatedStreetLamp = streetLamp.copyWith(isLit: isLit);
  final zoneStreetLamps =
      ref.read(zoneStreetLampsProvider(zone: streetLamp.street.zone).notifier);

  await zoneStreetLamps.addOrUpdate(updatedStreetLamp);
  state = AsyncData(updatedStreetLamp);
}
```

Deux écritures, deux sources, un ordre implicite. Si l'ordre change, si une étape échoue, si une troisième vue apparaît (recherche, map, favoris), les sources dérivent. C'est le smell classique qu'on rencontre dès qu'une entité est affichée à plusieurs endroits.

## Solution proposée : un store normalisé par entité

Inspiré de Redux EntityAdapter / NgRx Entity. **Un seul provider tient toutes les lamps indexées par id**, tout le reste dérive.

### Le store canonique

> **Stratégie : 100% pessimiste.** Toutes les mutations attendent la confirmation serveur avant de mettre à jour l'état. Pas d'optimiste, pas de rollback. Voir `command_pattern_consolidation.md` section 2 pour la justification complète (les animations UI locales donnent déjà le feedback instantané, l'optimiste n'apporterait rien).

```dart
@Riverpod(keepAlive: true)
class StreetLampStore extends _$StreetLampStore {
  late final StreetLampRemoteRepository _repo;

  @override
  Future<Map<String, StreetLamp>> build() async {
    _repo = ref.watch(streetLampRemoteRepositoryProvider);
    final zone = await ref.watch(selectedZoneProvider.future);
    final lamps = await _repo.getList(zone);
    return {for (final l in lamps) l.id: l};
  }

  Future toggle(String id) async {
    final store = state.value!;
    final lamp = store[id]!;
    final updated = lamp.copyWith(isLit: !lamp.isLit);

    await _repo.addOrUpdate(updated);                 // pessimiste
    state = AsyncData({...store, id: updated});       // une seule écriture, après succès
  }

  Future addOrUpdate(StreetLamp lamp) async {
    final saved = await _repo.addOrUpdate(lamp);      // pessimiste
    state = AsyncValue.data({...state.value!, saved.id: saved});
  }

  Future remove(String id) async {
    final lamp = state.value![id]!;
    await _repo.remove(lamp);                          // pessimiste
    state = AsyncValue.data({...state.value!}..remove(id));
  }
}
```

### Les vues dérivées

La liste et le détail deviennent des projections pures du store. On préserve l'`AsyncValue` (loading / error / data) via `whenData`, donc le `AsyncValueWidget` existant marche tel quel côté widget.

```dart
@riverpod
AsyncValue<IList<StreetLamp>> zoneLamps(
  ZoneLampsRef ref, {
  required CityZone zone,
}) {
  return ref.watch(streetLampStoreProvider).whenData(
        (store) => store.values
            .where((l) => l.street.zone == zone)
            .toIList()
            .sort(streetLampComparator),
      );
}

@riverpod
AsyncValue<StreetLamp> streetLamp(
  StreetLampRef ref, {
  required String id,
}) {
  return ref.watch(streetLampStoreProvider).whenData((store) => store[id]!);
}
```

Côté widget, rien ne change : `ref.watch(zoneLampsProvider(zone: zone))` renvoie toujours un `AsyncValue<IList<StreetLamp>>`. `LampDetails` watch `streetLampProvider(id:)` au lieu de `streetLampStateProvider`.

## Ce que ça élimine

- **La sync manuelle cross-provider.** `StreetLampState.updateLight` disparaît. `toggle`, `remove`, `addOrUpdate` vivent sur le store. Une écriture → toutes les vues cohérentes.
- **Le pass-through `LampList`.** Son `build` chain `selectedZone` → `zoneStreetLamps`, et `addOrUpdate` / `remove` / `refresh` délèguent tout (`lib/presentation/home/providers.dart`). Avec `zoneLamps` dérivé, le widget peut watcher directement et `LampList` devient inutile (ou se réduit à un cache de `selectedZone`).
- **Le `selectedZone` mutable en champ d'instance** dans `LampList` (`providers.dart:59`) — il disparaît avec le pass-through.
- **`AvailableStreets` se simplifie.** Aujourd'hui il watch `zoneStreetLampsProvider` + `streetsProvider` et fait une différence d'ensembles (`lib/domain/city_zones/providers.dart:31-39`). Avec le store, c'est `allStreets.where((s) => !store.values.any((l) => l.street == s))` — une seule source.
- **L'état local de `LitLampWidget`.** L'animation `_action` (`FlameAction { idle, turningOn, turningOff }`) reste widget-local — c'est l'état d'action visuel pendant l'appel serveur. Mais le flip de `isLit` côté data se fait quand le serveur confirme, dans une seule écriture du store. Plus besoin du mixte "optimiste UI + pessimiste data" qui rendait le code incohérent (`lib/presentation/street_lamp_details/lit_lamp_widget.dart:23-25`).

## Coûts et questions à trancher

C'est plus de machinery qu'un `update` manuel de 3 lignes. Deux points à décider :

### 1. Quand charge-t-on le store ?

Ici le `build` charge la zone sélectionnée. Pour scaler à plusieurs zones, deux options :

- tout charger à l'init (OK si peu de zones) ;
- charger paresseusement et merger au fur et à mesure (`state = AsyncData({...state.value!, ...newLamps})`). Garde l'idiome "load per zone" avec une seule source de vérité.

### 2. Le détail ouvert pour une lamp absente du store ?

Si on peut naviguer au détail sans passer par la liste (deep link, push notif), `store[id]` est absent. Soit un `load(id)` sur le store qui fait `repo.get(id)` + upsert, soit une fallback. Hors périmètre pour falotier — on arrive toujours par la liste.

## Est-ce que ça vaut le coup sur falotier ?

Pour 1 zone et 8 lamps, le `StreetLampState.updateLight` manuel fonctionne et est court. Le normalized store paye vraiment quand :

- plusieurs vues de la même entité (liste + détail + recherche + map) ;
- des mutations à synchroniser entre plusieurs vues (le cas de falotier : liste + détail) ;
- des entités référencées par d'autres (jointures normalisées) ;
- la cardinalité explose.

C'est donc davantage un investissement pour la prochaine app que pour ce PoC. Mais c'est le pattern canonique pour "single source of truth en Riverpod" : **un store normalisé par type d'entité, des vues dérivées via `whenData` + `select`, les mutations centralisées sur le store.** C'est ce qui manque le plus à l'écosystème, et que les gens réinventent mal à coup de sync cross-provider.
