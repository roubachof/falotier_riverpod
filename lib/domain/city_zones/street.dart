import 'package:freezed_annotation/freezed_annotation.dart';

import 'city_zone.dart';

part 'street.freezed.dart';

@freezed
class Street with _$Street {
  const factory Street(String id, String name, CityZone zone) = _Street;
}
