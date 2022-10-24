import 'package:freezed_annotation/freezed_annotation.dart';

part 'city_zone.freezed.dart';

@freezed
class CityZone with _$CityZone {
  const factory CityZone(String id, String name) = _CityZone;
}
