// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) {
  return _AccountModel.fromJson(json);
}

/// @nodoc
mixin _$AccountModel {
  bool get trialUsed => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get trialUsedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AccountModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AccountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountModelCopyWith<AccountModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountModelCopyWith<$Res> {
  factory $AccountModelCopyWith(
          AccountModel value, $Res Function(AccountModel) then) =
      _$AccountModelCopyWithImpl<$Res, AccountModel>;
  @useResult
  $Res call(
      {bool trialUsed,
      @NullableTimestampConverter() DateTime? trialUsedAt,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class _$AccountModelCopyWithImpl<$Res, $Val extends AccountModel>
    implements $AccountModelCopyWith<$Res> {
  _$AccountModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trialUsed = null,
    Object? trialUsedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      trialUsed: null == trialUsed
          ? _value.trialUsed
          : trialUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      trialUsedAt: freezed == trialUsedAt
          ? _value.trialUsedAt
          : trialUsedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountModelImplCopyWith<$Res>
    implements $AccountModelCopyWith<$Res> {
  factory _$$AccountModelImplCopyWith(
          _$AccountModelImpl value, $Res Function(_$AccountModelImpl) then) =
      __$$AccountModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool trialUsed,
      @NullableTimestampConverter() DateTime? trialUsedAt,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class __$$AccountModelImplCopyWithImpl<$Res>
    extends _$AccountModelCopyWithImpl<$Res, _$AccountModelImpl>
    implements _$$AccountModelImplCopyWith<$Res> {
  __$$AccountModelImplCopyWithImpl(
      _$AccountModelImpl _value, $Res Function(_$AccountModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AccountModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trialUsed = null,
    Object? trialUsedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$AccountModelImpl(
      trialUsed: null == trialUsed
          ? _value.trialUsed
          : trialUsed // ignore: cast_nullable_to_non_nullable
              as bool,
      trialUsedAt: freezed == trialUsedAt
          ? _value.trialUsedAt
          : trialUsedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountModelImpl implements _AccountModel {
  const _$AccountModelImpl(
      {required this.trialUsed,
      @NullableTimestampConverter() this.trialUsedAt,
      @TimestampConverter() required this.createdAt});

  factory _$AccountModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountModelImplFromJson(json);

  @override
  final bool trialUsed;
  @override
  @NullableTimestampConverter()
  final DateTime? trialUsedAt;
  @override
  @TimestampConverter()
  final DateTime createdAt;

  @override
  String toString() {
    return 'AccountModel(trialUsed: $trialUsed, trialUsedAt: $trialUsedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountModelImpl &&
            (identical(other.trialUsed, trialUsed) ||
                other.trialUsed == trialUsed) &&
            (identical(other.trialUsedAt, trialUsedAt) ||
                other.trialUsedAt == trialUsedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, trialUsed, trialUsedAt, createdAt);

  /// Create a copy of AccountModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountModelImplCopyWith<_$AccountModelImpl> get copyWith =>
      __$$AccountModelImplCopyWithImpl<_$AccountModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountModelImplToJson(
      this,
    );
  }
}

abstract class _AccountModel implements AccountModel {
  const factory _AccountModel(
          {required final bool trialUsed,
          @NullableTimestampConverter() final DateTime? trialUsedAt,
          @TimestampConverter() required final DateTime createdAt}) =
      _$AccountModelImpl;

  factory _AccountModel.fromJson(Map<String, dynamic> json) =
      _$AccountModelImpl.fromJson;

  @override
  bool get trialUsed;
  @override
  @NullableTimestampConverter()
  DateTime? get trialUsedAt;
  @override
  @TimestampConverter()
  DateTime get createdAt;

  /// Create a copy of AccountModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountModelImplCopyWith<_$AccountModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SchoolModel _$SchoolModelFromJson(Map<String, dynamic> json) {
  return _SchoolModel.fromJson(json);
}

/// @nodoc
mixin _$SchoolModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SchoolModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SchoolModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SchoolModelCopyWith<SchoolModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SchoolModelCopyWith<$Res> {
  factory $SchoolModelCopyWith(
          SchoolModel value, $Res Function(SchoolModel) then) =
      _$SchoolModelCopyWithImpl<$Res, SchoolModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$SchoolModelCopyWithImpl<$Res, $Val extends SchoolModel>
    implements $SchoolModelCopyWith<$Res> {
  _$SchoolModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SchoolModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SchoolModelImplCopyWith<$Res>
    implements $SchoolModelCopyWith<$Res> {
  factory _$$SchoolModelImplCopyWith(
          _$SchoolModelImpl value, $Res Function(_$SchoolModelImpl) then) =
      __$$SchoolModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$SchoolModelImplCopyWithImpl<$Res>
    extends _$SchoolModelCopyWithImpl<$Res, _$SchoolModelImpl>
    implements _$$SchoolModelImplCopyWith<$Res> {
  __$$SchoolModelImplCopyWithImpl(
      _$SchoolModelImpl _value, $Res Function(_$SchoolModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SchoolModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SchoolModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SchoolModelImpl implements _SchoolModel {
  const _$SchoolModelImpl(
      {required this.id,
      required this.name,
      this.description,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt});

  factory _$SchoolModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SchoolModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SchoolModel(id: $id, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SchoolModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, createdAt, updatedAt);

  /// Create a copy of SchoolModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SchoolModelImplCopyWith<_$SchoolModelImpl> get copyWith =>
      __$$SchoolModelImplCopyWithImpl<_$SchoolModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SchoolModelImplToJson(
      this,
    );
  }
}

abstract class _SchoolModel implements SchoolModel {
  const factory _SchoolModel(
          {required final String id,
          required final String name,
          final String? description,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$SchoolModelImpl;

  factory _SchoolModel.fromJson(Map<String, dynamic> json) =
      _$SchoolModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of SchoolModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SchoolModelImplCopyWith<_$SchoolModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PeriodModel _$PeriodModelFromJson(Map<String, dynamic> json) {
  return _PeriodModel.fromJson(json);
}

/// @nodoc
mixin _$PeriodModel {
  String get id => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // 'LESSON' | 'BREAK'
  String? get name =>
      throw _privateConstructorUsedError; // required for BREAK, optional for LESSON
  String get startTime => throw _privateConstructorUsedError; // 'HH:mm'
  String get endTime => throw _privateConstructorUsedError; // 'HH:mm'
  int get sortOrder => throw _privateConstructorUsedError;
  List<String>? get dayApplicability => throw _privateConstructorUsedError;

  /// Serializes this PeriodModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PeriodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeriodModelCopyWith<PeriodModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeriodModelCopyWith<$Res> {
  factory $PeriodModelCopyWith(
          PeriodModel value, $Res Function(PeriodModel) then) =
      _$PeriodModelCopyWithImpl<$Res, PeriodModel>;
  @useResult
  $Res call(
      {String id,
      String schoolId,
      String type,
      String? name,
      String startTime,
      String endTime,
      int sortOrder,
      List<String>? dayApplicability});
}

/// @nodoc
class _$PeriodModelCopyWithImpl<$Res, $Val extends PeriodModel>
    implements $PeriodModelCopyWith<$Res> {
  _$PeriodModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PeriodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = null,
    Object? type = null,
    Object? name = freezed,
    Object? startTime = null,
    Object? endTime = null,
    Object? sortOrder = null,
    Object? dayApplicability = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      dayApplicability: freezed == dayApplicability
          ? _value.dayApplicability
          : dayApplicability // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PeriodModelImplCopyWith<$Res>
    implements $PeriodModelCopyWith<$Res> {
  factory _$$PeriodModelImplCopyWith(
          _$PeriodModelImpl value, $Res Function(_$PeriodModelImpl) then) =
      __$$PeriodModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String schoolId,
      String type,
      String? name,
      String startTime,
      String endTime,
      int sortOrder,
      List<String>? dayApplicability});
}

/// @nodoc
class __$$PeriodModelImplCopyWithImpl<$Res>
    extends _$PeriodModelCopyWithImpl<$Res, _$PeriodModelImpl>
    implements _$$PeriodModelImplCopyWith<$Res> {
  __$$PeriodModelImplCopyWithImpl(
      _$PeriodModelImpl _value, $Res Function(_$PeriodModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PeriodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = null,
    Object? type = null,
    Object? name = freezed,
    Object? startTime = null,
    Object? endTime = null,
    Object? sortOrder = null,
    Object? dayApplicability = freezed,
  }) {
    return _then(_$PeriodModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      dayApplicability: freezed == dayApplicability
          ? _value._dayApplicability
          : dayApplicability // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PeriodModelImpl implements _PeriodModel {
  const _$PeriodModelImpl(
      {required this.id,
      required this.schoolId,
      required this.type,
      this.name,
      required this.startTime,
      required this.endTime,
      required this.sortOrder,
      final List<String>? dayApplicability})
      : _dayApplicability = dayApplicability;

  factory _$PeriodModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeriodModelImplFromJson(json);

  @override
  final String id;
  @override
  final String schoolId;
  @override
  final String type;
// 'LESSON' | 'BREAK'
  @override
  final String? name;
// required for BREAK, optional for LESSON
  @override
  final String startTime;
// 'HH:mm'
  @override
  final String endTime;
// 'HH:mm'
  @override
  final int sortOrder;
  final List<String>? _dayApplicability;
  @override
  List<String>? get dayApplicability {
    final value = _dayApplicability;
    if (value == null) return null;
    if (_dayApplicability is EqualUnmodifiableListView)
      return _dayApplicability;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PeriodModel(id: $id, schoolId: $schoolId, type: $type, name: $name, startTime: $startTime, endTime: $endTime, sortOrder: $sortOrder, dayApplicability: $dayApplicability)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeriodModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            const DeepCollectionEquality()
                .equals(other._dayApplicability, _dayApplicability));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      schoolId,
      type,
      name,
      startTime,
      endTime,
      sortOrder,
      const DeepCollectionEquality().hash(_dayApplicability));

  /// Create a copy of PeriodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeriodModelImplCopyWith<_$PeriodModelImpl> get copyWith =>
      __$$PeriodModelImplCopyWithImpl<_$PeriodModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PeriodModelImplToJson(
      this,
    );
  }
}

abstract class _PeriodModel implements PeriodModel {
  const factory _PeriodModel(
      {required final String id,
      required final String schoolId,
      required final String type,
      final String? name,
      required final String startTime,
      required final String endTime,
      required final int sortOrder,
      final List<String>? dayApplicability}) = _$PeriodModelImpl;

  factory _PeriodModel.fromJson(Map<String, dynamic> json) =
      _$PeriodModelImpl.fromJson;

  @override
  String get id;
  @override
  String get schoolId;
  @override
  String get type; // 'LESSON' | 'BREAK'
  @override
  String? get name; // required for BREAK, optional for LESSON
  @override
  String get startTime; // 'HH:mm'
  @override
  String get endTime; // 'HH:mm'
  @override
  int get sortOrder;
  @override
  List<String>? get dayApplicability;

  /// Create a copy of PeriodModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeriodModelImplCopyWith<_$PeriodModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DayCapacityModel _$DayCapacityModelFromJson(Map<String, dynamic> json) {
  return _DayCapacityModel.fromJson(json);
}

/// @nodoc
mixin _$DayCapacityModel {
  String get schoolId => throw _privateConstructorUsedError;
  String get classroomId => throw _privateConstructorUsedError;
  String get dayOfWeek =>
      throw _privateConstructorUsedError; // 'MON'|'TUE'|'WED'|'THU'|'FRI'|'SAT'|'SUN'
  List<int> get activeSlots => throw _privateConstructorUsedError;

  /// Serializes this DayCapacityModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DayCapacityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayCapacityModelCopyWith<DayCapacityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayCapacityModelCopyWith<$Res> {
  factory $DayCapacityModelCopyWith(
          DayCapacityModel value, $Res Function(DayCapacityModel) then) =
      _$DayCapacityModelCopyWithImpl<$Res, DayCapacityModel>;
  @useResult
  $Res call(
      {String schoolId,
      String classroomId,
      String dayOfWeek,
      List<int> activeSlots});
}

/// @nodoc
class _$DayCapacityModelCopyWithImpl<$Res, $Val extends DayCapacityModel>
    implements $DayCapacityModelCopyWith<$Res> {
  _$DayCapacityModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DayCapacityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schoolId = null,
    Object? classroomId = null,
    Object? dayOfWeek = null,
    Object? activeSlots = null,
  }) {
    return _then(_value.copyWith(
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String,
      activeSlots: null == activeSlots
          ? _value.activeSlots
          : activeSlots // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DayCapacityModelImplCopyWith<$Res>
    implements $DayCapacityModelCopyWith<$Res> {
  factory _$$DayCapacityModelImplCopyWith(_$DayCapacityModelImpl value,
          $Res Function(_$DayCapacityModelImpl) then) =
      __$$DayCapacityModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String schoolId,
      String classroomId,
      String dayOfWeek,
      List<int> activeSlots});
}

/// @nodoc
class __$$DayCapacityModelImplCopyWithImpl<$Res>
    extends _$DayCapacityModelCopyWithImpl<$Res, _$DayCapacityModelImpl>
    implements _$$DayCapacityModelImplCopyWith<$Res> {
  __$$DayCapacityModelImplCopyWithImpl(_$DayCapacityModelImpl _value,
      $Res Function(_$DayCapacityModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DayCapacityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? schoolId = null,
    Object? classroomId = null,
    Object? dayOfWeek = null,
    Object? activeSlots = null,
  }) {
    return _then(_$DayCapacityModelImpl(
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String,
      activeSlots: null == activeSlots
          ? _value._activeSlots
          : activeSlots // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DayCapacityModelImpl implements _DayCapacityModel {
  const _$DayCapacityModelImpl(
      {required this.schoolId,
      required this.classroomId,
      required this.dayOfWeek,
      required final List<int> activeSlots})
      : _activeSlots = activeSlots;

  factory _$DayCapacityModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DayCapacityModelImplFromJson(json);

  @override
  final String schoolId;
  @override
  final String classroomId;
  @override
  final String dayOfWeek;
// 'MON'|'TUE'|'WED'|'THU'|'FRI'|'SAT'|'SUN'
  final List<int> _activeSlots;
// 'MON'|'TUE'|'WED'|'THU'|'FRI'|'SAT'|'SUN'
  @override
  List<int> get activeSlots {
    if (_activeSlots is EqualUnmodifiableListView) return _activeSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeSlots);
  }

  @override
  String toString() {
    return 'DayCapacityModel(schoolId: $schoolId, classroomId: $classroomId, dayOfWeek: $dayOfWeek, activeSlots: $activeSlots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayCapacityModelImpl &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.classroomId, classroomId) ||
                other.classroomId == classroomId) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            const DeepCollectionEquality()
                .equals(other._activeSlots, _activeSlots));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, schoolId, classroomId, dayOfWeek,
      const DeepCollectionEquality().hash(_activeSlots));

  /// Create a copy of DayCapacityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayCapacityModelImplCopyWith<_$DayCapacityModelImpl> get copyWith =>
      __$$DayCapacityModelImplCopyWithImpl<_$DayCapacityModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DayCapacityModelImplToJson(
      this,
    );
  }
}

abstract class _DayCapacityModel implements DayCapacityModel {
  const factory _DayCapacityModel(
      {required final String schoolId,
      required final String classroomId,
      required final String dayOfWeek,
      required final List<int> activeSlots}) = _$DayCapacityModelImpl;

  factory _DayCapacityModel.fromJson(Map<String, dynamic> json) =
      _$DayCapacityModelImpl.fromJson;

  @override
  String get schoolId;
  @override
  String get classroomId;
  @override
  String get dayOfWeek; // 'MON'|'TUE'|'WED'|'THU'|'FRI'|'SAT'|'SUN'
  @override
  List<int> get activeSlots;

  /// Create a copy of DayCapacityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayCapacityModelImplCopyWith<_$DayCapacityModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClassroomModel _$ClassroomModelFromJson(Map<String, dynamic> json) {
  return _ClassroomModel.fromJson(json);
}

/// @nodoc
mixin _$ClassroomModel {
  String get id => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this ClassroomModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassroomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassroomModelCopyWith<ClassroomModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomModelCopyWith<$Res> {
  factory $ClassroomModelCopyWith(
          ClassroomModel value, $Res Function(ClassroomModel) then) =
      _$ClassroomModelCopyWithImpl<$Res, ClassroomModel>;
  @useResult
  $Res call({String id, String schoolId, String name, int sortOrder});
}

/// @nodoc
class _$ClassroomModelCopyWithImpl<$Res, $Val extends ClassroomModel>
    implements $ClassroomModelCopyWith<$Res> {
  _$ClassroomModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassroomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = null,
    Object? name = null,
    Object? sortOrder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomModelImplCopyWith<$Res>
    implements $ClassroomModelCopyWith<$Res> {
  factory _$$ClassroomModelImplCopyWith(_$ClassroomModelImpl value,
          $Res Function(_$ClassroomModelImpl) then) =
      __$$ClassroomModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String schoolId, String name, int sortOrder});
}

/// @nodoc
class __$$ClassroomModelImplCopyWithImpl<$Res>
    extends _$ClassroomModelCopyWithImpl<$Res, _$ClassroomModelImpl>
    implements _$$ClassroomModelImplCopyWith<$Res> {
  __$$ClassroomModelImplCopyWithImpl(
      _$ClassroomModelImpl _value, $Res Function(_$ClassroomModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClassroomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = null,
    Object? name = null,
    Object? sortOrder = null,
  }) {
    return _then(_$ClassroomModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassroomModelImpl implements _ClassroomModel {
  const _$ClassroomModelImpl(
      {required this.id,
      required this.schoolId,
      required this.name,
      required this.sortOrder});

  factory _$ClassroomModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassroomModelImplFromJson(json);

  @override
  final String id;
  @override
  final String schoolId;
  @override
  final String name;
  @override
  final int sortOrder;

  @override
  String toString() {
    return 'ClassroomModel(id: $id, schoolId: $schoolId, name: $name, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, schoolId, name, sortOrder);

  /// Create a copy of ClassroomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomModelImplCopyWith<_$ClassroomModelImpl> get copyWith =>
      __$$ClassroomModelImplCopyWithImpl<_$ClassroomModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassroomModelImplToJson(
      this,
    );
  }
}

abstract class _ClassroomModel implements ClassroomModel {
  const factory _ClassroomModel(
      {required final String id,
      required final String schoolId,
      required final String name,
      required final int sortOrder}) = _$ClassroomModelImpl;

  factory _ClassroomModel.fromJson(Map<String, dynamic> json) =
      _$ClassroomModelImpl.fromJson;

  @override
  String get id;
  @override
  String get schoolId;
  @override
  String get name;
  @override
  int get sortOrder;

  /// Create a copy of ClassroomModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassroomModelImplCopyWith<_$ClassroomModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubjectModel _$SubjectModelFromJson(Map<String, dynamic> json) {
  return _SubjectModel.fromJson(json);
}

/// @nodoc
mixin _$SubjectModel {
  String get id => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get teacherName => throw _privateConstructorUsedError;
  String? get teacherId =>
      throw _privateConstructorUsedError; // null in v1.0; FK to Teacher collection in v2.0
  String get colourHex => throw _privateConstructorUsedError;

  /// Serializes this SubjectModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectModelCopyWith<SubjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectModelCopyWith<$Res> {
  factory $SubjectModelCopyWith(
          SubjectModel value, $Res Function(SubjectModel) then) =
      _$SubjectModelCopyWithImpl<$Res, SubjectModel>;
  @useResult
  $Res call(
      {String id,
      String schoolId,
      String name,
      String teacherName,
      String? teacherId,
      String colourHex});
}

/// @nodoc
class _$SubjectModelCopyWithImpl<$Res, $Val extends SubjectModel>
    implements $SubjectModelCopyWith<$Res> {
  _$SubjectModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = null,
    Object? name = null,
    Object? teacherName = null,
    Object? teacherId = freezed,
    Object? colourHex = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      teacherName: null == teacherName
          ? _value.teacherName
          : teacherName // ignore: cast_nullable_to_non_nullable
              as String,
      teacherId: freezed == teacherId
          ? _value.teacherId
          : teacherId // ignore: cast_nullable_to_non_nullable
              as String?,
      colourHex: null == colourHex
          ? _value.colourHex
          : colourHex // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubjectModelImplCopyWith<$Res>
    implements $SubjectModelCopyWith<$Res> {
  factory _$$SubjectModelImplCopyWith(
          _$SubjectModelImpl value, $Res Function(_$SubjectModelImpl) then) =
      __$$SubjectModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String schoolId,
      String name,
      String teacherName,
      String? teacherId,
      String colourHex});
}

/// @nodoc
class __$$SubjectModelImplCopyWithImpl<$Res>
    extends _$SubjectModelCopyWithImpl<$Res, _$SubjectModelImpl>
    implements _$$SubjectModelImplCopyWith<$Res> {
  __$$SubjectModelImplCopyWithImpl(
      _$SubjectModelImpl _value, $Res Function(_$SubjectModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = null,
    Object? name = null,
    Object? teacherName = null,
    Object? teacherId = freezed,
    Object? colourHex = null,
  }) {
    return _then(_$SubjectModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      teacherName: null == teacherName
          ? _value.teacherName
          : teacherName // ignore: cast_nullable_to_non_nullable
              as String,
      teacherId: freezed == teacherId
          ? _value.teacherId
          : teacherId // ignore: cast_nullable_to_non_nullable
              as String?,
      colourHex: null == colourHex
          ? _value.colourHex
          : colourHex // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubjectModelImpl implements _SubjectModel {
  const _$SubjectModelImpl(
      {required this.id,
      required this.schoolId,
      required this.name,
      required this.teacherName,
      this.teacherId,
      required this.colourHex});

  factory _$SubjectModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectModelImplFromJson(json);

  @override
  final String id;
  @override
  final String schoolId;
  @override
  final String name;
  @override
  final String teacherName;
  @override
  final String? teacherId;
// null in v1.0; FK to Teacher collection in v2.0
  @override
  final String colourHex;

  @override
  String toString() {
    return 'SubjectModel(id: $id, schoolId: $schoolId, name: $name, teacherName: $teacherName, teacherId: $teacherId, colourHex: $colourHex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.colourHex, colourHex) ||
                other.colourHex == colourHex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, schoolId, name, teacherName, teacherId, colourHex);

  /// Create a copy of SubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectModelImplCopyWith<_$SubjectModelImpl> get copyWith =>
      __$$SubjectModelImplCopyWithImpl<_$SubjectModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectModelImplToJson(
      this,
    );
  }
}

abstract class _SubjectModel implements SubjectModel {
  const factory _SubjectModel(
      {required final String id,
      required final String schoolId,
      required final String name,
      required final String teacherName,
      final String? teacherId,
      required final String colourHex}) = _$SubjectModelImpl;

  factory _SubjectModel.fromJson(Map<String, dynamic> json) =
      _$SubjectModelImpl.fromJson;

  @override
  String get id;
  @override
  String get schoolId;
  @override
  String get name;
  @override
  String get teacherName;
  @override
  String? get teacherId; // null in v1.0; FK to Teacher collection in v2.0
  @override
  String get colourHex;

  /// Create a copy of SubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectModelImplCopyWith<_$SubjectModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClassroomSubjectModel _$ClassroomSubjectModelFromJson(
    Map<String, dynamic> json) {
  return _ClassroomSubjectModel.fromJson(json);
}

/// @nodoc
mixin _$ClassroomSubjectModel {
  String get id => throw _privateConstructorUsedError; // Firestore doc ID
  String get classroomId => throw _privateConstructorUsedError;
  String get subjectId => throw _privateConstructorUsedError;
  int get weeklyTargetHours => throw _privateConstructorUsedError;
  int get minDailyHours => throw _privateConstructorUsedError; // 0 = disabled
  int get maxDailyHours => throw _privateConstructorUsedError;

  /// Serializes this ClassroomSubjectModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassroomSubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassroomSubjectModelCopyWith<ClassroomSubjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomSubjectModelCopyWith<$Res> {
  factory $ClassroomSubjectModelCopyWith(ClassroomSubjectModel value,
          $Res Function(ClassroomSubjectModel) then) =
      _$ClassroomSubjectModelCopyWithImpl<$Res, ClassroomSubjectModel>;
  @useResult
  $Res call(
      {String id,
      String classroomId,
      String subjectId,
      int weeklyTargetHours,
      int minDailyHours,
      int maxDailyHours});
}

/// @nodoc
class _$ClassroomSubjectModelCopyWithImpl<$Res,
        $Val extends ClassroomSubjectModel>
    implements $ClassroomSubjectModelCopyWith<$Res> {
  _$ClassroomSubjectModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassroomSubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classroomId = null,
    Object? subjectId = null,
    Object? weeklyTargetHours = null,
    Object? minDailyHours = null,
    Object? maxDailyHours = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      weeklyTargetHours: null == weeklyTargetHours
          ? _value.weeklyTargetHours
          : weeklyTargetHours // ignore: cast_nullable_to_non_nullable
              as int,
      minDailyHours: null == minDailyHours
          ? _value.minDailyHours
          : minDailyHours // ignore: cast_nullable_to_non_nullable
              as int,
      maxDailyHours: null == maxDailyHours
          ? _value.maxDailyHours
          : maxDailyHours // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomSubjectModelImplCopyWith<$Res>
    implements $ClassroomSubjectModelCopyWith<$Res> {
  factory _$$ClassroomSubjectModelImplCopyWith(
          _$ClassroomSubjectModelImpl value,
          $Res Function(_$ClassroomSubjectModelImpl) then) =
      __$$ClassroomSubjectModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String classroomId,
      String subjectId,
      int weeklyTargetHours,
      int minDailyHours,
      int maxDailyHours});
}

/// @nodoc
class __$$ClassroomSubjectModelImplCopyWithImpl<$Res>
    extends _$ClassroomSubjectModelCopyWithImpl<$Res,
        _$ClassroomSubjectModelImpl>
    implements _$$ClassroomSubjectModelImplCopyWith<$Res> {
  __$$ClassroomSubjectModelImplCopyWithImpl(_$ClassroomSubjectModelImpl _value,
      $Res Function(_$ClassroomSubjectModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClassroomSubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classroomId = null,
    Object? subjectId = null,
    Object? weeklyTargetHours = null,
    Object? minDailyHours = null,
    Object? maxDailyHours = null,
  }) {
    return _then(_$ClassroomSubjectModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      weeklyTargetHours: null == weeklyTargetHours
          ? _value.weeklyTargetHours
          : weeklyTargetHours // ignore: cast_nullable_to_non_nullable
              as int,
      minDailyHours: null == minDailyHours
          ? _value.minDailyHours
          : minDailyHours // ignore: cast_nullable_to_non_nullable
              as int,
      maxDailyHours: null == maxDailyHours
          ? _value.maxDailyHours
          : maxDailyHours // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassroomSubjectModelImpl implements _ClassroomSubjectModel {
  const _$ClassroomSubjectModelImpl(
      {required this.id,
      required this.classroomId,
      required this.subjectId,
      required this.weeklyTargetHours,
      this.minDailyHours = 0,
      required this.maxDailyHours});

  factory _$ClassroomSubjectModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassroomSubjectModelImplFromJson(json);

  @override
  final String id;
// Firestore doc ID
  @override
  final String classroomId;
  @override
  final String subjectId;
  @override
  final int weeklyTargetHours;
  @override
  @JsonKey()
  final int minDailyHours;
// 0 = disabled
  @override
  final int maxDailyHours;

  @override
  String toString() {
    return 'ClassroomSubjectModel(id: $id, classroomId: $classroomId, subjectId: $subjectId, weeklyTargetHours: $weeklyTargetHours, minDailyHours: $minDailyHours, maxDailyHours: $maxDailyHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomSubjectModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.classroomId, classroomId) ||
                other.classroomId == classroomId) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.weeklyTargetHours, weeklyTargetHours) ||
                other.weeklyTargetHours == weeklyTargetHours) &&
            (identical(other.minDailyHours, minDailyHours) ||
                other.minDailyHours == minDailyHours) &&
            (identical(other.maxDailyHours, maxDailyHours) ||
                other.maxDailyHours == maxDailyHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, classroomId, subjectId,
      weeklyTargetHours, minDailyHours, maxDailyHours);

  /// Create a copy of ClassroomSubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomSubjectModelImplCopyWith<_$ClassroomSubjectModelImpl>
      get copyWith => __$$ClassroomSubjectModelImplCopyWithImpl<
          _$ClassroomSubjectModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassroomSubjectModelImplToJson(
      this,
    );
  }
}

abstract class _ClassroomSubjectModel implements ClassroomSubjectModel {
  const factory _ClassroomSubjectModel(
      {required final String id,
      required final String classroomId,
      required final String subjectId,
      required final int weeklyTargetHours,
      final int minDailyHours,
      required final int maxDailyHours}) = _$ClassroomSubjectModelImpl;

  factory _ClassroomSubjectModel.fromJson(Map<String, dynamic> json) =
      _$ClassroomSubjectModelImpl.fromJson;

  @override
  String get id; // Firestore doc ID
  @override
  String get classroomId;
  @override
  String get subjectId;
  @override
  int get weeklyTargetHours;
  @override
  int get minDailyHours; // 0 = disabled
  @override
  int get maxDailyHours;

  /// Create a copy of ClassroomSubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassroomSubjectModelImplCopyWith<_$ClassroomSubjectModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ConstraintModel _$ConstraintModelFromJson(Map<String, dynamic> json) {
  return _ConstraintModel.fromJson(json);
}

/// @nodoc
mixin _$ConstraintModel {
  String get id => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get kind => throw _privateConstructorUsedError; // 'HARD' | 'SOFT'
  String get type =>
      throw _privateConstructorUsedError; // 'MUST_ASSIGN' | 'MUST_NOT_ASSIGN' |
// 'AVOID_TIMESLOT' | 'PREFER_BLOCK' | 'DAILY_LIMIT'
  String? get classroomId => throw _privateConstructorUsedError;
  String? get subjectId => throw _privateConstructorUsedError;
  String? get dayOfWeek => throw _privateConstructorUsedError;
  String? get periodId => throw _privateConstructorUsedError;
  String? get endPeriodId =>
      throw _privateConstructorUsedError; // AVOID_TIMESLOT only
  String? get weight =>
      throw _privateConstructorUsedError; // 'LOW' | 'MEDIUM' | 'HIGH' (SOFT only)
  int? get minHours =>
      throw _privateConstructorUsedError; // DAILY_LIMIT only (0/null = no minimum)
  int? get maxHours => throw _privateConstructorUsedError;

  /// Serializes this ConstraintModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConstraintModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConstraintModelCopyWith<ConstraintModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConstraintModelCopyWith<$Res> {
  factory $ConstraintModelCopyWith(
          ConstraintModel value, $Res Function(ConstraintModel) then) =
      _$ConstraintModelCopyWithImpl<$Res, ConstraintModel>;
  @useResult
  $Res call(
      {String id,
      String schoolId,
      String kind,
      String type,
      String? classroomId,
      String? subjectId,
      String? dayOfWeek,
      String? periodId,
      String? endPeriodId,
      String? weight,
      int? minHours,
      int? maxHours});
}

/// @nodoc
class _$ConstraintModelCopyWithImpl<$Res, $Val extends ConstraintModel>
    implements $ConstraintModelCopyWith<$Res> {
  _$ConstraintModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConstraintModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = null,
    Object? kind = null,
    Object? type = null,
    Object? classroomId = freezed,
    Object? subjectId = freezed,
    Object? dayOfWeek = freezed,
    Object? periodId = freezed,
    Object? endPeriodId = freezed,
    Object? weight = freezed,
    Object? minHours = freezed,
    Object? maxHours = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: freezed == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String?,
      subjectId: freezed == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String?,
      dayOfWeek: freezed == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String?,
      periodId: freezed == periodId
          ? _value.periodId
          : periodId // ignore: cast_nullable_to_non_nullable
              as String?,
      endPeriodId: freezed == endPeriodId
          ? _value.endPeriodId
          : endPeriodId // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      minHours: freezed == minHours
          ? _value.minHours
          : minHours // ignore: cast_nullable_to_non_nullable
              as int?,
      maxHours: freezed == maxHours
          ? _value.maxHours
          : maxHours // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConstraintModelImplCopyWith<$Res>
    implements $ConstraintModelCopyWith<$Res> {
  factory _$$ConstraintModelImplCopyWith(_$ConstraintModelImpl value,
          $Res Function(_$ConstraintModelImpl) then) =
      __$$ConstraintModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String schoolId,
      String kind,
      String type,
      String? classroomId,
      String? subjectId,
      String? dayOfWeek,
      String? periodId,
      String? endPeriodId,
      String? weight,
      int? minHours,
      int? maxHours});
}

/// @nodoc
class __$$ConstraintModelImplCopyWithImpl<$Res>
    extends _$ConstraintModelCopyWithImpl<$Res, _$ConstraintModelImpl>
    implements _$$ConstraintModelImplCopyWith<$Res> {
  __$$ConstraintModelImplCopyWithImpl(
      _$ConstraintModelImpl _value, $Res Function(_$ConstraintModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConstraintModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = null,
    Object? kind = null,
    Object? type = null,
    Object? classroomId = freezed,
    Object? subjectId = freezed,
    Object? dayOfWeek = freezed,
    Object? periodId = freezed,
    Object? endPeriodId = freezed,
    Object? weight = freezed,
    Object? minHours = freezed,
    Object? maxHours = freezed,
  }) {
    return _then(_$ConstraintModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: freezed == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String?,
      subjectId: freezed == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String?,
      dayOfWeek: freezed == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as String?,
      periodId: freezed == periodId
          ? _value.periodId
          : periodId // ignore: cast_nullable_to_non_nullable
              as String?,
      endPeriodId: freezed == endPeriodId
          ? _value.endPeriodId
          : endPeriodId // ignore: cast_nullable_to_non_nullable
              as String?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as String?,
      minHours: freezed == minHours
          ? _value.minHours
          : minHours // ignore: cast_nullable_to_non_nullable
              as int?,
      maxHours: freezed == maxHours
          ? _value.maxHours
          : maxHours // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConstraintModelImpl implements _ConstraintModel {
  const _$ConstraintModelImpl(
      {required this.id,
      required this.schoolId,
      required this.kind,
      required this.type,
      this.classroomId,
      this.subjectId,
      this.dayOfWeek,
      this.periodId,
      this.endPeriodId,
      this.weight,
      this.minHours,
      this.maxHours});

  factory _$ConstraintModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConstraintModelImplFromJson(json);

  @override
  final String id;
  @override
  final String schoolId;
  @override
  final String kind;
// 'HARD' | 'SOFT'
  @override
  final String type;
// 'MUST_ASSIGN' | 'MUST_NOT_ASSIGN' |
// 'AVOID_TIMESLOT' | 'PREFER_BLOCK' | 'DAILY_LIMIT'
  @override
  final String? classroomId;
  @override
  final String? subjectId;
  @override
  final String? dayOfWeek;
  @override
  final String? periodId;
  @override
  final String? endPeriodId;
// AVOID_TIMESLOT only
  @override
  final String? weight;
// 'LOW' | 'MEDIUM' | 'HIGH' (SOFT only)
  @override
  final int? minHours;
// DAILY_LIMIT only (0/null = no minimum)
  @override
  final int? maxHours;

  @override
  String toString() {
    return 'ConstraintModel(id: $id, schoolId: $schoolId, kind: $kind, type: $type, classroomId: $classroomId, subjectId: $subjectId, dayOfWeek: $dayOfWeek, periodId: $periodId, endPeriodId: $endPeriodId, weight: $weight, minHours: $minHours, maxHours: $maxHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConstraintModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.classroomId, classroomId) ||
                other.classroomId == classroomId) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.periodId, periodId) ||
                other.periodId == periodId) &&
            (identical(other.endPeriodId, endPeriodId) ||
                other.endPeriodId == endPeriodId) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.minHours, minHours) ||
                other.minHours == minHours) &&
            (identical(other.maxHours, maxHours) ||
                other.maxHours == maxHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      schoolId,
      kind,
      type,
      classroomId,
      subjectId,
      dayOfWeek,
      periodId,
      endPeriodId,
      weight,
      minHours,
      maxHours);

  /// Create a copy of ConstraintModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConstraintModelImplCopyWith<_$ConstraintModelImpl> get copyWith =>
      __$$ConstraintModelImplCopyWithImpl<_$ConstraintModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConstraintModelImplToJson(
      this,
    );
  }
}

abstract class _ConstraintModel implements ConstraintModel {
  const factory _ConstraintModel(
      {required final String id,
      required final String schoolId,
      required final String kind,
      required final String type,
      final String? classroomId,
      final String? subjectId,
      final String? dayOfWeek,
      final String? periodId,
      final String? endPeriodId,
      final String? weight,
      final int? minHours,
      final int? maxHours}) = _$ConstraintModelImpl;

  factory _ConstraintModel.fromJson(Map<String, dynamic> json) =
      _$ConstraintModelImpl.fromJson;

  @override
  String get id;
  @override
  String get schoolId;
  @override
  String get kind; // 'HARD' | 'SOFT'
  @override
  String get type; // 'MUST_ASSIGN' | 'MUST_NOT_ASSIGN' |
// 'AVOID_TIMESLOT' | 'PREFER_BLOCK' | 'DAILY_LIMIT'
  @override
  String? get classroomId;
  @override
  String? get subjectId;
  @override
  String? get dayOfWeek;
  @override
  String? get periodId;
  @override
  String? get endPeriodId; // AVOID_TIMESLOT only
  @override
  String? get weight; // 'LOW' | 'MEDIUM' | 'HIGH' (SOFT only)
  @override
  int? get minHours; // DAILY_LIMIT only (0/null = no minimum)
  @override
  int? get maxHours;

  /// Create a copy of ConstraintModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConstraintModelImplCopyWith<_$ConstraintModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) {
  return _ScheduleModel.fromJson(json);
}

/// @nodoc
mixin _$ScheduleModel {
  String get id => throw _privateConstructorUsedError;
  String get schoolId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get generatedAt => throw _privateConstructorUsedError;
  bool get isCancelled => throw _privateConstructorUsedError;
  bool get isManuallyEdited => throw _privateConstructorUsedError;
  String get resultStatus =>
      throw _privateConstructorUsedError; // 'PERFECT'|'SOFT_VIOLATIONS'|'HARD_VIOLATIONS'
  int get hardViolationCount => throw _privateConstructorUsedError;
  int get softViolationCount => throw _privateConstructorUsedError;
  int get qualityScore => throw _privateConstructorUsedError; // 0-100
  int get teacherFreeHours => throw _privateConstructorUsedError;
  int get subjectChanges => throw _privateConstructorUsedError;

  /// Serializes this ScheduleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleModelCopyWith<ScheduleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleModelCopyWith<$Res> {
  factory $ScheduleModelCopyWith(
          ScheduleModel value, $Res Function(ScheduleModel) then) =
      _$ScheduleModelCopyWithImpl<$Res, ScheduleModel>;
  @useResult
  $Res call(
      {String id,
      String schoolId,
      String name,
      @TimestampConverter() DateTime generatedAt,
      bool isCancelled,
      bool isManuallyEdited,
      String resultStatus,
      int hardViolationCount,
      int softViolationCount,
      int qualityScore,
      int teacherFreeHours,
      int subjectChanges});
}

/// @nodoc
class _$ScheduleModelCopyWithImpl<$Res, $Val extends ScheduleModel>
    implements $ScheduleModelCopyWith<$Res> {
  _$ScheduleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = null,
    Object? name = null,
    Object? generatedAt = null,
    Object? isCancelled = null,
    Object? isManuallyEdited = null,
    Object? resultStatus = null,
    Object? hardViolationCount = null,
    Object? softViolationCount = null,
    Object? qualityScore = null,
    Object? teacherFreeHours = null,
    Object? subjectChanges = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCancelled: null == isCancelled
          ? _value.isCancelled
          : isCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      isManuallyEdited: null == isManuallyEdited
          ? _value.isManuallyEdited
          : isManuallyEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      resultStatus: null == resultStatus
          ? _value.resultStatus
          : resultStatus // ignore: cast_nullable_to_non_nullable
              as String,
      hardViolationCount: null == hardViolationCount
          ? _value.hardViolationCount
          : hardViolationCount // ignore: cast_nullable_to_non_nullable
              as int,
      softViolationCount: null == softViolationCount
          ? _value.softViolationCount
          : softViolationCount // ignore: cast_nullable_to_non_nullable
              as int,
      qualityScore: null == qualityScore
          ? _value.qualityScore
          : qualityScore // ignore: cast_nullable_to_non_nullable
              as int,
      teacherFreeHours: null == teacherFreeHours
          ? _value.teacherFreeHours
          : teacherFreeHours // ignore: cast_nullable_to_non_nullable
              as int,
      subjectChanges: null == subjectChanges
          ? _value.subjectChanges
          : subjectChanges // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleModelImplCopyWith<$Res>
    implements $ScheduleModelCopyWith<$Res> {
  factory _$$ScheduleModelImplCopyWith(
          _$ScheduleModelImpl value, $Res Function(_$ScheduleModelImpl) then) =
      __$$ScheduleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String schoolId,
      String name,
      @TimestampConverter() DateTime generatedAt,
      bool isCancelled,
      bool isManuallyEdited,
      String resultStatus,
      int hardViolationCount,
      int softViolationCount,
      int qualityScore,
      int teacherFreeHours,
      int subjectChanges});
}

/// @nodoc
class __$$ScheduleModelImplCopyWithImpl<$Res>
    extends _$ScheduleModelCopyWithImpl<$Res, _$ScheduleModelImpl>
    implements _$$ScheduleModelImplCopyWith<$Res> {
  __$$ScheduleModelImplCopyWithImpl(
      _$ScheduleModelImpl _value, $Res Function(_$ScheduleModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schoolId = null,
    Object? name = null,
    Object? generatedAt = null,
    Object? isCancelled = null,
    Object? isManuallyEdited = null,
    Object? resultStatus = null,
    Object? hardViolationCount = null,
    Object? softViolationCount = null,
    Object? qualityScore = null,
    Object? teacherFreeHours = null,
    Object? subjectChanges = null,
  }) {
    return _then(_$ScheduleModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      schoolId: null == schoolId
          ? _value.schoolId
          : schoolId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCancelled: null == isCancelled
          ? _value.isCancelled
          : isCancelled // ignore: cast_nullable_to_non_nullable
              as bool,
      isManuallyEdited: null == isManuallyEdited
          ? _value.isManuallyEdited
          : isManuallyEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      resultStatus: null == resultStatus
          ? _value.resultStatus
          : resultStatus // ignore: cast_nullable_to_non_nullable
              as String,
      hardViolationCount: null == hardViolationCount
          ? _value.hardViolationCount
          : hardViolationCount // ignore: cast_nullable_to_non_nullable
              as int,
      softViolationCount: null == softViolationCount
          ? _value.softViolationCount
          : softViolationCount // ignore: cast_nullable_to_non_nullable
              as int,
      qualityScore: null == qualityScore
          ? _value.qualityScore
          : qualityScore // ignore: cast_nullable_to_non_nullable
              as int,
      teacherFreeHours: null == teacherFreeHours
          ? _value.teacherFreeHours
          : teacherFreeHours // ignore: cast_nullable_to_non_nullable
              as int,
      subjectChanges: null == subjectChanges
          ? _value.subjectChanges
          : subjectChanges // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleModelImpl implements _ScheduleModel {
  const _$ScheduleModelImpl(
      {required this.id,
      required this.schoolId,
      required this.name,
      @TimestampConverter() required this.generatedAt,
      this.isCancelled = false,
      this.isManuallyEdited = false,
      required this.resultStatus,
      this.hardViolationCount = 0,
      this.softViolationCount = 0,
      this.qualityScore = 0,
      this.teacherFreeHours = 0,
      this.subjectChanges = 0});

  factory _$ScheduleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleModelImplFromJson(json);

  @override
  final String id;
  @override
  final String schoolId;
  @override
  final String name;
  @override
  @TimestampConverter()
  final DateTime generatedAt;
  @override
  @JsonKey()
  final bool isCancelled;
  @override
  @JsonKey()
  final bool isManuallyEdited;
  @override
  final String resultStatus;
// 'PERFECT'|'SOFT_VIOLATIONS'|'HARD_VIOLATIONS'
  @override
  @JsonKey()
  final int hardViolationCount;
  @override
  @JsonKey()
  final int softViolationCount;
  @override
  @JsonKey()
  final int qualityScore;
// 0-100
  @override
  @JsonKey()
  final int teacherFreeHours;
  @override
  @JsonKey()
  final int subjectChanges;

  @override
  String toString() {
    return 'ScheduleModel(id: $id, schoolId: $schoolId, name: $name, generatedAt: $generatedAt, isCancelled: $isCancelled, isManuallyEdited: $isManuallyEdited, resultStatus: $resultStatus, hardViolationCount: $hardViolationCount, softViolationCount: $softViolationCount, qualityScore: $qualityScore, teacherFreeHours: $teacherFreeHours, subjectChanges: $subjectChanges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.schoolId, schoolId) ||
                other.schoolId == schoolId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.isCancelled, isCancelled) ||
                other.isCancelled == isCancelled) &&
            (identical(other.isManuallyEdited, isManuallyEdited) ||
                other.isManuallyEdited == isManuallyEdited) &&
            (identical(other.resultStatus, resultStatus) ||
                other.resultStatus == resultStatus) &&
            (identical(other.hardViolationCount, hardViolationCount) ||
                other.hardViolationCount == hardViolationCount) &&
            (identical(other.softViolationCount, softViolationCount) ||
                other.softViolationCount == softViolationCount) &&
            (identical(other.qualityScore, qualityScore) ||
                other.qualityScore == qualityScore) &&
            (identical(other.teacherFreeHours, teacherFreeHours) ||
                other.teacherFreeHours == teacherFreeHours) &&
            (identical(other.subjectChanges, subjectChanges) ||
                other.subjectChanges == subjectChanges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      schoolId,
      name,
      generatedAt,
      isCancelled,
      isManuallyEdited,
      resultStatus,
      hardViolationCount,
      softViolationCount,
      qualityScore,
      teacherFreeHours,
      subjectChanges);

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleModelImplCopyWith<_$ScheduleModelImpl> get copyWith =>
      __$$ScheduleModelImplCopyWithImpl<_$ScheduleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleModelImplToJson(
      this,
    );
  }
}

abstract class _ScheduleModel implements ScheduleModel {
  const factory _ScheduleModel(
      {required final String id,
      required final String schoolId,
      required final String name,
      @TimestampConverter() required final DateTime generatedAt,
      final bool isCancelled,
      final bool isManuallyEdited,
      required final String resultStatus,
      final int hardViolationCount,
      final int softViolationCount,
      final int qualityScore,
      final int teacherFreeHours,
      final int subjectChanges}) = _$ScheduleModelImpl;

  factory _ScheduleModel.fromJson(Map<String, dynamic> json) =
      _$ScheduleModelImpl.fromJson;

  @override
  String get id;
  @override
  String get schoolId;
  @override
  String get name;
  @override
  @TimestampConverter()
  DateTime get generatedAt;
  @override
  bool get isCancelled;
  @override
  bool get isManuallyEdited;
  @override
  String get resultStatus; // 'PERFECT'|'SOFT_VIOLATIONS'|'HARD_VIOLATIONS'
  @override
  int get hardViolationCount;
  @override
  int get softViolationCount;
  @override
  int get qualityScore; // 0-100
  @override
  int get teacherFreeHours;
  @override
  int get subjectChanges;

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleModelImplCopyWith<_$ScheduleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduleCellModel _$ScheduleCellModelFromJson(Map<String, dynamic> json) {
  return _ScheduleCellModel.fromJson(json);
}

/// @nodoc
mixin _$ScheduleCellModel {
  String get id => throw _privateConstructorUsedError;
  String get scheduleId => throw _privateConstructorUsedError;
  String get classroomId => throw _privateConstructorUsedError;
  String get periodId =>
      throw _privateConstructorUsedError; // LESSON Period Firestore ID
  String? get subjectId =>
      throw _privateConstructorUsedError; // null = free slot
  bool get isViolation => throw _privateConstructorUsedError;
  String? get violationDescription => throw _privateConstructorUsedError;

  /// Serializes this ScheduleCellModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleCellModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleCellModelCopyWith<ScheduleCellModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleCellModelCopyWith<$Res> {
  factory $ScheduleCellModelCopyWith(
          ScheduleCellModel value, $Res Function(ScheduleCellModel) then) =
      _$ScheduleCellModelCopyWithImpl<$Res, ScheduleCellModel>;
  @useResult
  $Res call(
      {String id,
      String scheduleId,
      String classroomId,
      String periodId,
      String? subjectId,
      bool isViolation,
      String? violationDescription});
}

/// @nodoc
class _$ScheduleCellModelCopyWithImpl<$Res, $Val extends ScheduleCellModel>
    implements $ScheduleCellModelCopyWith<$Res> {
  _$ScheduleCellModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleCellModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scheduleId = null,
    Object? classroomId = null,
    Object? periodId = null,
    Object? subjectId = freezed,
    Object? isViolation = null,
    Object? violationDescription = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      periodId: null == periodId
          ? _value.periodId
          : periodId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: freezed == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String?,
      isViolation: null == isViolation
          ? _value.isViolation
          : isViolation // ignore: cast_nullable_to_non_nullable
              as bool,
      violationDescription: freezed == violationDescription
          ? _value.violationDescription
          : violationDescription // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleCellModelImplCopyWith<$Res>
    implements $ScheduleCellModelCopyWith<$Res> {
  factory _$$ScheduleCellModelImplCopyWith(_$ScheduleCellModelImpl value,
          $Res Function(_$ScheduleCellModelImpl) then) =
      __$$ScheduleCellModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String scheduleId,
      String classroomId,
      String periodId,
      String? subjectId,
      bool isViolation,
      String? violationDescription});
}

/// @nodoc
class __$$ScheduleCellModelImplCopyWithImpl<$Res>
    extends _$ScheduleCellModelCopyWithImpl<$Res, _$ScheduleCellModelImpl>
    implements _$$ScheduleCellModelImplCopyWith<$Res> {
  __$$ScheduleCellModelImplCopyWithImpl(_$ScheduleCellModelImpl _value,
      $Res Function(_$ScheduleCellModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScheduleCellModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scheduleId = null,
    Object? classroomId = null,
    Object? periodId = null,
    Object? subjectId = freezed,
    Object? isViolation = null,
    Object? violationDescription = freezed,
  }) {
    return _then(_$ScheduleCellModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String,
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      periodId: null == periodId
          ? _value.periodId
          : periodId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: freezed == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String?,
      isViolation: null == isViolation
          ? _value.isViolation
          : isViolation // ignore: cast_nullable_to_non_nullable
              as bool,
      violationDescription: freezed == violationDescription
          ? _value.violationDescription
          : violationDescription // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleCellModelImpl implements _ScheduleCellModel {
  const _$ScheduleCellModelImpl(
      {required this.id,
      required this.scheduleId,
      required this.classroomId,
      required this.periodId,
      this.subjectId,
      this.isViolation = false,
      this.violationDescription});

  factory _$ScheduleCellModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleCellModelImplFromJson(json);

  @override
  final String id;
  @override
  final String scheduleId;
  @override
  final String classroomId;
  @override
  final String periodId;
// LESSON Period Firestore ID
  @override
  final String? subjectId;
// null = free slot
  @override
  @JsonKey()
  final bool isViolation;
  @override
  final String? violationDescription;

  @override
  String toString() {
    return 'ScheduleCellModel(id: $id, scheduleId: $scheduleId, classroomId: $classroomId, periodId: $periodId, subjectId: $subjectId, isViolation: $isViolation, violationDescription: $violationDescription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleCellModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.classroomId, classroomId) ||
                other.classroomId == classroomId) &&
            (identical(other.periodId, periodId) ||
                other.periodId == periodId) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.isViolation, isViolation) ||
                other.isViolation == isViolation) &&
            (identical(other.violationDescription, violationDescription) ||
                other.violationDescription == violationDescription));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, scheduleId, classroomId,
      periodId, subjectId, isViolation, violationDescription);

  /// Create a copy of ScheduleCellModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleCellModelImplCopyWith<_$ScheduleCellModelImpl> get copyWith =>
      __$$ScheduleCellModelImplCopyWithImpl<_$ScheduleCellModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleCellModelImplToJson(
      this,
    );
  }
}

abstract class _ScheduleCellModel implements ScheduleCellModel {
  const factory _ScheduleCellModel(
      {required final String id,
      required final String scheduleId,
      required final String classroomId,
      required final String periodId,
      final String? subjectId,
      final bool isViolation,
      final String? violationDescription}) = _$ScheduleCellModelImpl;

  factory _ScheduleCellModel.fromJson(Map<String, dynamic> json) =
      _$ScheduleCellModelImpl.fromJson;

  @override
  String get id;
  @override
  String get scheduleId;
  @override
  String get classroomId;
  @override
  String get periodId; // LESSON Period Firestore ID
  @override
  String? get subjectId; // null = free slot
  @override
  bool get isViolation;
  @override
  String? get violationDescription;

  /// Create a copy of ScheduleCellModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleCellModelImplCopyWith<_$ScheduleCellModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
