import 'package:freezed_annotation/freezed_annotation.dart';

import 'city_zone.dart';

part 'street.freezed.dart';

int streetComparator(Street s1, Street s2) {
  final firstComparison = s1.districtNumber.compareTo(s2.districtNumber);
  if (firstComparison != 0) {
    return firstComparison;
  }

  return s1.name.compareTo(s2.name);
}

@freezed
class Street with _$Street {
  Street._();
  factory Street(
    String id,
    CityZone zone,
    int districtNumber,
    String name,
    String description,
    String imageAsset,
  ) = _Street;

  late final String districtDisplay = 'Arrondissement n°$districtNumber';
}
