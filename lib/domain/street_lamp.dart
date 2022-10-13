import 'package:freezed_annotation/freezed_annotation.dart';

part 'street_lamp.freezed.dart';

@freezed
class StreetLamp with _$StreetLamp {
  const factory StreetLamp({
    required String streetName,
    required bool isLit,
  }) = _StreetLamp;
}
