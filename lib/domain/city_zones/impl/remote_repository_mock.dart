import 'package:falotier/domain/city_zones/interfaces.dart';
import 'package:falotier/infrastructure/logger_factory.dart';
import 'package:falotier/infrastructure/remote_call_emulator.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../city_zone.dart';
import '../street.dart';

final cityZoneRemoteRepositoryMockProvider =
    Provider((ref) => CityZoneRemoteRepositoryMock());

class CityZoneRemoteRepositoryMock implements CityZoneRemoteRepository {
  static final _log = LoggerFactory.logger('CityZoneRepository');
  static const defaultZone = CityZone('1', 'Paris');

  static int _nextId = 1001;

  final _emulator = RemoteCallEmulator(exceptionProbability: 0.5);

  final IList<CityZone> _zones = IList<CityZone>(const [defaultZone]);

  late final Map<CityZone, IList<Street>> _streetByZone = _createStreets();

  @override
  Future<IList<CityZone>> getAvailableZones() async {
    _log.i('getAvailableZones');
    await _emulator.makeRemoteCall();
    _log.listCount(_zones);
    return _zones;
  }

  @override
  Future<IList<Street>> getZoneStreets(CityZone zone) async {
    _log.i('getZoneStreets( $zone )');
    await _emulator.makeRemoteCall();
    final streets = _streetByZone[zone]!;
    _log.listCount(streets);
    return streets;
  }

  Map<CityZone, IList<Street>> _createStreets() {
    return {
      defaultZone: IList<Street>([
        _createStreet(
          17,
          'Rue Nollet',
          'L\'abbé Jean-Antoine Nollet (1700-1770) physicien français; '
              'quartier où ont été groupés des noms de savants.\n'
              'Précédemment rue Saint-Louis. Elles est indiquée sur le plan '
              'cadastral de 1825.',
          'nollet.jpg',
        ),
        _createStreet(
            5,
            'Rue du Chat-qui-Pêche',
            'Avec une largeur maximale de 1,80 mètre, elle est parfois présentée '
                'comme la rue la plus étroite de la capitale. Ce titre est '
                'toutefois en compétition avec le sentier des Merisiers '
                '(large de 90 cm) dans le 12e arrondissement. Elle part du 9, '
                'quai Saint-Michel et se termine à hauteur du 12, rue de la '
                'Huchette, pour une longueur de 29 mètres.\n'
                'Elle doit son nom à l’enseigne d’un ancien commerce qui s’y '
                'trouvait. Ce commerce de poissons était la propriété d\'un '
                'chanoine du nom de Dom Perlet dont le chat noir, d\'une grande '
                'habileté, était célèbre pour sa capacité à extraire des poissons '
                'de la Seine d\'un simple coup de patte.',
            'chat.jpg'),
        _createStreet(
            16,
            'Rue de la Pompe',
            'Dû à la pompe qui fournissait l\'eau au château de la Muette.\n'
                'Elle est tracée à l\'état de chemin sur le plan de Roussel (1730).',
            'pompe.jpg'),
        _createStreet(
          20,
          'Rue de Ménilmontant',
          'Cette rue provient d\'un ancien chemin qui conduisait à un '
              'hameau formé autour d\'un mesnil ou villa, appelée dans une '
              'charte de 1224 mesnolium mali temporis (« mesnil du mauvais '
              'temps ») et dans un autre de 1231 mesnilium mautenz '
              'appellation transformée vers le xvie siècle en « Mesnil '
              'montant ».\n'
              'Cette voie de l\'ancienne commune de Belleville tracée sur le '
              'plan de Jouvin de Rochefort de 1672 porta le nom de '
              '« chemin du Ménil-Mautemps », « chaussée de Ménilmontant » '
              'et « avenue de Ménilmontant ». Un décret du 7 janvier 1813, '
              'rapporté le 25 juillet 1851, avait classé cette voie comme '
              '« route départementale no 27 ».',
          'menilmontant.jpg',
        ),
        _createStreet(
            17,
            'Rue des Moines',
            'Probablement les moines de Saint-Denis, par opposition à la rue '
                'des Dames de l'
                'Abbaye de Montmartre, qui en est voisine.\n'
                'Précédemment Chemin des Moines. Cette voie paraît occuper l\'emplacement '
                'd\'un chemin indiqué sur le plan de Roussel (1730) entre le chemin des Boeufs '
                '(actuellement rue de La Jonquière) et la place de Lévis.',
            'moines.jpg'),
        _createStreet(
            1,
            'Halles de Paris',
            'Les Halles de Paris était le nom donné aux halles centrales, '
                'marché de vente en gros de produits alimentaires frais, situé '
                'au cœur de Paris, dans le 1er arrondissement, et qui donna son '
                'nom au quartier environnant. Au plus fort de son activité et '
                'par manque de place, les étals des marchands s\'installaient '
                'même dans les rues adjacentes.\n'
                'Elles sont le décor principal du Ventre de Paris d\'Émile Zola.',
            'halles.jpg'),
        _createStreet(
            9,
            'Rue Rodier',
            'Elle porte le nom de Jean-Baptiste Rodier (1763-1832), '
                'sous-gouverneur de la Banque de France et propriétaire des '
                'terrains.\n'
                'La « cité Rodier », ouverte en 1833 sur les terrains '
                'appartenant à Jean-Baptiste Rodier, devint rue en 1855 et '
                'prit alors le nom de « rue Rodier ».',
            'rodier.jpg'),
        _createStreet(
          13,
          'Butte-aux-Cailles',
          'À l\'origine, c\'est une colline recouverte de prairies, de vignes '
              'et de bois, construite de plusieurs moulins à vent et '
              'surplombant la Bièvre de 28 mètres. La Butte-aux-Cailles tire '
              'son nom de Pierre Caille, qui en fait l\'acquisition en 1543.\n'
              'Au XVIIe siècle, l\'exploitation minière des calcaires coquilliers '
              'est pratiquée, mais les nombreuses activités industrielles '
              'utilisant l\'eau de la Bièvre, telles que teintureries, '
              'tanneries, blanchisseries, mégisseries, et même boucheries, '
              'rendent ce quartier insalubre.',
          'cailles.jpg',
        ),
        _createStreet(
            20,
            'Rue de Belleville',
            'Principale rue de l\'ancien village de Belleville, qui tient '
                'son nom de la déformation du terme « Belle vue », Belleville '
                'étant avant son intégration dans Paris la colline la plus '
                'haute de la banlieue de la capitale, devant celle de '
                'Montmartre. Existant déjà en 1670, cette rue se nomma '
                '« rue de Paris » et « rue du Parc ».\n'
                'Situé à la hauteur de l\'actuel métro Belleville, le mur des '
                'Fermiers généraux séparait en haut de la rue du '
                'Faubourg-du-Temple la basse Courtille, dans Paris, de la '
                'haute Courtille hors Paris. Cette dernière, située au bas de '
                'l\'actuelle rue de Belleville, était simplement connue comme '
                'la Courtille. C\'était un très célèbre lieu de distractions '
                'parisien. On venait y boire et manger moins cher qu\'à Paris, '
                'car dans des établissements ne payant pas les droits de douane '
                'de l\'octroi parisien.',
            'belleville.jpg'),
      ])
    };
  }

  Street _createStreet(
    int districtNumber,
    String name,
    String description,
    String imageAsset, {
    CityZone cityZone = CityZoneRemoteRepositoryMock.defaultZone,
  }) {
    return Street(
      '${_nextId++}',
      cityZone,
      districtNumber,
      name,
      description,
      imageAsset,
    );
  }
}
