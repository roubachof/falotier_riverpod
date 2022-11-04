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
  String get id => throw _privateConstructorUsedError;
  Street get street => throw _privateConstructorUsedError;
  bool get isLit => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StreetLampCopyWith<StreetLamp> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreetLampCopyWith<$Res> {
  factory $StreetLampCopyWith(
          StreetLamp value, $Res Function(StreetLamp) then) =
      _$StreetLampCopyWithImpl<$Res, StreetLamp>;
  @useResult
  $Res call({String id, Street street, bool isLit});

  $StreetCopyWith<$Res> get street;
}

/// @nodoc
class _$StreetLampCopyWithImpl<$Res, $Val extends StreetLamp>
    implements $StreetLampCopyWith<$Res> {
  _$StreetLampCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? street = null,
    Object? isLit = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as Street,
      isLit: null == isLit
          ? _value.isLit
          : isLit // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $StreetCopyWith<$Res> get street {
    return $StreetCopyWith<$Res>(_value.street, (value) {
      return _then(_value.copyWith(street: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_StreetLampCopyWith<$Res>
    implements $StreetLampCopyWith<$Res> {
  factory _$$_StreetLampCopyWith(
          _$_StreetLamp value, $Res Function(_$_StreetLamp) then) =
      __$$_StreetLampCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, Street street, bool isLit});

  @override
  $StreetCopyWith<$Res> get street;
}

/// @nodoc
class __$$_StreetLampCopyWithImpl<$Res>
    extends _$StreetLampCopyWithImpl<$Res, _$_StreetLamp>
    implements _$$_StreetLampCopyWith<$Res> {
  __$$_StreetLampCopyWithImpl(
      _$_StreetLamp _value, $Res Function(_$_StreetLamp) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? street = null,
    Object? isLit = null,
  }) {
    return _then(_$_StreetLamp(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as Street,
      isLit: null == isLit
          ? _value.isLit
          : isLit // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_StreetLamp extends _StreetLamp {
  const _$_StreetLamp(
      {required this.id, required this.street, required this.isLit})
      : super._();

  @override
  final String id;
  @override
  final Street street;
  @override
  final bool isLit;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_StreetLamp &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.isLit, isLit) || other.isLit == isLit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, street, isLit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_StreetLampCopyWith<_$_StreetLamp> get copyWith =>
      __$$_StreetLampCopyWithImpl<_$_StreetLamp>(this, _$identity);
}

abstract class _StreetLamp extends StreetLamp {
  const factory _StreetLamp(
      {required final String id,
      required final Street street,
      required final bool isLit}) = _$_StreetLamp;
  const _StreetLamp._() : super._();

  @override
  String get id;
  @override
  Street get street;
  @override
  bool get isLit;
  @override
  @JsonKey(ignore: true)
  _$$_StreetLampCopyWith<_$_StreetLamp> get copyWith =>
      throw _privateConstructorUsedError;
}
