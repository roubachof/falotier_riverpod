// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'street.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Street {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  CityZone get zone => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StreetCopyWith<Street> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreetCopyWith<$Res> {
  factory $StreetCopyWith(Street value, $Res Function(Street) then) =
      _$StreetCopyWithImpl<$Res>;
  $Res call({String id, String name, CityZone zone});

  $CityZoneCopyWith<$Res> get zone;
}

/// @nodoc
class _$StreetCopyWithImpl<$Res> implements $StreetCopyWith<$Res> {
  _$StreetCopyWithImpl(this._value, this._then);

  final Street _value;
  // ignore: unused_field
  final $Res Function(Street) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? zone = freezed,
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
      zone: zone == freezed
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as CityZone,
    ));
  }

  @override
  $CityZoneCopyWith<$Res> get zone {
    return $CityZoneCopyWith<$Res>(_value.zone, (value) {
      return _then(_value.copyWith(zone: value));
    });
  }
}

/// @nodoc
abstract class _$$_StreetCopyWith<$Res> implements $StreetCopyWith<$Res> {
  factory _$$_StreetCopyWith(_$_Street value, $Res Function(_$_Street) then) =
      __$$_StreetCopyWithImpl<$Res>;
  @override
  $Res call({String id, String name, CityZone zone});

  @override
  $CityZoneCopyWith<$Res> get zone;
}

/// @nodoc
class __$$_StreetCopyWithImpl<$Res> extends _$StreetCopyWithImpl<$Res>
    implements _$$_StreetCopyWith<$Res> {
  __$$_StreetCopyWithImpl(_$_Street _value, $Res Function(_$_Street) _then)
      : super(_value, (v) => _then(v as _$_Street));

  @override
  _$_Street get _value => super._value as _$_Street;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? zone = freezed,
  }) {
    return _then(_$_Street(
      id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      zone == freezed
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as CityZone,
    ));
  }
}

/// @nodoc

class _$_Street implements _Street {
  const _$_Street(this.id, this.name, this.zone);

  @override
  final String id;
  @override
  final String name;
  @override
  final CityZone zone;

  @override
  String toString() {
    return 'Street(id: $id, name: $name, zone: $zone)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Street &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.zone, zone));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(zone));

  @JsonKey(ignore: true)
  @override
  _$$_StreetCopyWith<_$_Street> get copyWith =>
      __$$_StreetCopyWithImpl<_$_Street>(this, _$identity);
}

abstract class _Street implements Street {
  const factory _Street(
      final String id, final String name, final CityZone zone) = _$_Street;

  @override
  String get id;
  @override
  String get name;
  @override
  CityZone get zone;
  @override
  @JsonKey(ignore: true)
  _$$_StreetCopyWith<_$_Street> get copyWith =>
      throw _privateConstructorUsedError;
}
