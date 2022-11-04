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
  CityZone get zone => throw _privateConstructorUsedError;
  int get districtNumber => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageAsset => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StreetCopyWith<Street> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreetCopyWith<$Res> {
  factory $StreetCopyWith(Street value, $Res Function(Street) then) =
      _$StreetCopyWithImpl<$Res, Street>;
  @useResult
  $Res call(
      {String id,
      CityZone zone,
      int districtNumber,
      String name,
      String description,
      String imageAsset});

  $CityZoneCopyWith<$Res> get zone;
}

/// @nodoc
class _$StreetCopyWithImpl<$Res, $Val extends Street>
    implements $StreetCopyWith<$Res> {
  _$StreetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? zone = null,
    Object? districtNumber = null,
    Object? name = null,
    Object? description = null,
    Object? imageAsset = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      zone: null == zone
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as CityZone,
      districtNumber: null == districtNumber
          ? _value.districtNumber
          : districtNumber // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageAsset: null == imageAsset
          ? _value.imageAsset
          : imageAsset // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CityZoneCopyWith<$Res> get zone {
    return $CityZoneCopyWith<$Res>(_value.zone, (value) {
      return _then(_value.copyWith(zone: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_StreetCopyWith<$Res> implements $StreetCopyWith<$Res> {
  factory _$$_StreetCopyWith(_$_Street value, $Res Function(_$_Street) then) =
      __$$_StreetCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      CityZone zone,
      int districtNumber,
      String name,
      String description,
      String imageAsset});

  @override
  $CityZoneCopyWith<$Res> get zone;
}

/// @nodoc
class __$$_StreetCopyWithImpl<$Res>
    extends _$StreetCopyWithImpl<$Res, _$_Street>
    implements _$$_StreetCopyWith<$Res> {
  __$$_StreetCopyWithImpl(_$_Street _value, $Res Function(_$_Street) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? zone = null,
    Object? districtNumber = null,
    Object? name = null,
    Object? description = null,
    Object? imageAsset = null,
  }) {
    return _then(_$_Street(
      null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      null == zone
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as CityZone,
      null == districtNumber
          ? _value.districtNumber
          : districtNumber // ignore: cast_nullable_to_non_nullable
              as int,
      null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      null == imageAsset
          ? _value.imageAsset
          : imageAsset // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_Street extends _Street {
  _$_Street(this.id, this.zone, this.districtNumber, this.name,
      this.description, this.imageAsset)
      : super._();

  @override
  final String id;
  @override
  final CityZone zone;
  @override
  final int districtNumber;
  @override
  final String name;
  @override
  final String description;
  @override
  final String imageAsset;

  @override
  String toString() {
    return 'Street(id: $id, zone: $zone, districtNumber: $districtNumber, name: $name, description: $description, imageAsset: $imageAsset)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Street &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.zone, zone) || other.zone == zone) &&
            (identical(other.districtNumber, districtNumber) ||
                other.districtNumber == districtNumber) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageAsset, imageAsset) ||
                other.imageAsset == imageAsset));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, zone, districtNumber, name, description, imageAsset);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_StreetCopyWith<_$_Street> get copyWith =>
      __$$_StreetCopyWithImpl<_$_Street>(this, _$identity);
}

abstract class _Street extends Street {
  factory _Street(
      final String id,
      final CityZone zone,
      final int districtNumber,
      final String name,
      final String description,
      final String imageAsset) = _$_Street;
  _Street._() : super._();

  @override
  String get id;
  @override
  CityZone get zone;
  @override
  int get districtNumber;
  @override
  String get name;
  @override
  String get description;
  @override
  String get imageAsset;
  @override
  @JsonKey(ignore: true)
  _$$_StreetCopyWith<_$_Street> get copyWith =>
      throw _privateConstructorUsedError;
}
