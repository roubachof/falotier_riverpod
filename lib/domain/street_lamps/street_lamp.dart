import 'package:falotier/domain/city_zones/street.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'street_lamp.freezed.dart';

int streetLampComparator(StreetLamp s1, StreetLamp s2) {
  return streetComparator(s1.street, s2.street);
}

@freezed
class StreetLamp with _$StreetLamp {
  const StreetLamp._();
  const factory StreetLamp({
    required String id,
    required Street street,
    required bool isLit,
  }) = _StreetLamp;

  factory StreetLamp.fromStreet(Street street) {
    return StreetLamp(id: "new", street: street, isLit: false);
  }

  @override
  String toString() {
    return 'StreetLamp( id: $id, name: ${street.name}, isLit: $isLit )';
  }
}
