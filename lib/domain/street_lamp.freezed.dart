// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'street_lamp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$StreetLamp {
  String get streetName => throw _privateConstructorUsedError;
  bool get isLit => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StreetLampCopyWith<StreetLamp> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreetLampCopyWith<$Res> {
  factory $StreetLampCopyWith(
          StreetLamp value, $Res Function(StreetLamp) then) =
      _$StreetLampCopyWithImpl<$Res>;
  $Res call({String streetName, bool isLit});
}

/// @nodoc
class _$StreetLampCopyWithImpl<$Res> implements $StreetLampCopyWith<$Res> {
  _$StreetLampCopyWithImpl(this._value, this._then);

  final StreetLamp _value;
  // ignore: unused_field
  final $Res Function(StreetLamp) _then;

  @override
  $Res call({
    Object? streetName = freezed,
    Object? isLit = freezed,
  }) {
    return _then(_value.copyWith(
      streetName: streetName == freezed
          ? _value.streetName
          : streetName // ignore: cast_nullable_to_non_nullable
              as String,
      isLit: isLit == freezed
          ? _value.isLit
          : isLit // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$$_StreetLampCopyWith<$Res>
    implements $StreetLampCopyWith<$Res> {
  factory _$$_StreetLampCopyWith(
          _$_StreetLamp value, $Res Function(_$_StreetLamp) then) =
      __$$_StreetLampCopyWithImpl<$Res>;
  @override
  $Res call({String streetName, bool isLit});
}

/// @nodoc
class __$$_StreetLampCopyWithImpl<$Res> extends _$StreetLampCopyWithImpl<$Res>
    implements _$$_StreetLampCopyWith<$Res> {
  __$$_StreetLampCopyWithImpl(
      _$_StreetLamp _value, $Res Function(_$_StreetLamp) _then)
      : super(_value, (v) => _then(v as _$_StreetLamp));

  @override
  _$_StreetLamp get _value => super._value as _$_StreetLamp;

  @override
  $Res call({
    Object? streetName = freezed,
    Object? isLit = freezed,
  }) {
    return _then(_$_StreetLamp(
      streetName: streetName == freezed
          ? _value.streetName
          : streetName // ignore: cast_nullable_to_non_nullable
              as String,
      isLit: isLit == freezed
          ? _value.isLit
          : isLit // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_StreetLamp implements _StreetLamp {
  const _$_StreetLamp({required this.streetName, required this.isLit});

  @override
  final String streetName;
  @override
  final bool isLit;

  @override
  String toString() {
    return 'StreetLamp(streetName: $streetName, isLit: $isLit)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_StreetLamp &&
            const DeepCollectionEquality()
                .equals(other.streetName, streetName) &&
            const DeepCollectionEquality().equals(other.isLit, isLit));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(streetName),
      const DeepCollectionEquality().hash(isLit));

  @JsonKey(ignore: true)
  @override
  _$$_StreetLampCopyWith<_$_StreetLamp> get copyWith =>
      __$$_StreetLampCopyWithImpl<_$_StreetLamp>(this, _$identity);
}

abstract class _StreetLamp implements StreetLamp {
  const factory _StreetLamp(
      {required final String streetName,
      required final bool isLit}) = _$_StreetLamp;

  @override
  String get streetName;
  @override
  bool get isLit;
  @override
  @JsonKey(ignore: true)
  _$$_StreetLampCopyWith<_$_StreetLamp> get copyWith =>
      throw _privateConstructorUsedError;
}
