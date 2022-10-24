// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'city_zone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$CityZone {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CityZoneCopyWith<CityZone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityZoneCopyWith<$Res> {
  factory $CityZoneCopyWith(CityZone value, $Res Function(CityZone) then) =
      _$CityZoneCopyWithImpl<$Res>;
  $Res call({String id, String name});
}

/// @nodoc
class _$CityZoneCopyWithImpl<$Res> implements $CityZoneCopyWith<$Res> {
  _$CityZoneCopyWithImpl(this._value, this._then);

  final CityZone _value;
  // ignore: unused_field
  final $Res Function(CityZone) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_CityZoneCopyWith<$Res> implements $CityZoneCopyWith<$Res> {
  factory _$$_CityZoneCopyWith(
          _$_CityZone value, $Res Function(_$_CityZone) then) =
      __$$_CityZoneCopyWithImpl<$Res>;
  @override
  $Res call({String id, String name});
}

/// @nodoc
class __$$_CityZoneCopyWithImpl<$Res> extends _$CityZoneCopyWithImpl<$Res>
    implements _$$_CityZoneCopyWith<$Res> {
  __$$_CityZoneCopyWithImpl(
      _$_CityZone _value, $Res Function(_$_CityZone) _then)
      : super(_value, (v) => _then(v as _$_CityZone));

  @override
  _$_CityZone get _value => super._value as _$_CityZone;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
  }) {
    return _then(_$_CityZone(
      id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_CityZone implements _CityZone {
  const _$_CityZone(this.id, this.name);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'CityZone(id: $id, name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CityZone &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name));

  @JsonKey(ignore: true)
  @override
  _$$_CityZoneCopyWith<_$_CityZone> get copyWith =>
      __$$_CityZoneCopyWithImpl<_$_CityZone>(this, _$identity);
}

abstract class _CityZone implements CityZone {
  const factory _CityZone(final String id, final String name) = _$_CityZone;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$_CityZoneCopyWith<_$_CityZone> get copyWith =>
      throw _privateConstructorUsedError;
}
