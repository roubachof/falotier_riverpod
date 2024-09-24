// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'city_zone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CityZone {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Create a copy of CityZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CityZoneCopyWith<CityZone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CityZoneCopyWith<$Res> {
  factory $CityZoneCopyWith(CityZone value, $Res Function(CityZone) then) =
      _$CityZoneCopyWithImpl<$Res, CityZone>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$CityZoneCopyWithImpl<$Res, $Val extends CityZone>
    implements $CityZoneCopyWith<$Res> {
  _$CityZoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CityZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CityZoneImplCopyWith<$Res>
    implements $CityZoneCopyWith<$Res> {
  factory _$$CityZoneImplCopyWith(
          _$CityZoneImpl value, $Res Function(_$CityZoneImpl) then) =
      __$$CityZoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$CityZoneImplCopyWithImpl<$Res>
    extends _$CityZoneCopyWithImpl<$Res, _$CityZoneImpl>
    implements _$$CityZoneImplCopyWith<$Res> {
  __$$CityZoneImplCopyWithImpl(
      _$CityZoneImpl _value, $Res Function(_$CityZoneImpl) _then)
      : super(_value, _then);

  /// Create a copy of CityZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$CityZoneImpl(
      null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CityZoneImpl implements _CityZone {
  const _$CityZoneImpl(this.id, this.name);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'CityZone(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CityZoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of CityZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CityZoneImplCopyWith<_$CityZoneImpl> get copyWith =>
      __$$CityZoneImplCopyWithImpl<_$CityZoneImpl>(this, _$identity);
}

abstract class _CityZone implements CityZone {
  const factory _CityZone(final String id, final String name) = _$CityZoneImpl;

  @override
  String get id;
  @override
  String get name;

  /// Create a copy of CityZone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CityZoneImplCopyWith<_$CityZoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
