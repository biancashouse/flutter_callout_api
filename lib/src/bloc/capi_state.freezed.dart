// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capi_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$CAPIState {
  bool get localTestingFilePaths =>
      throw _privateConstructorUsedError; // because filepaths and fonts accedd differently in own package
  Map<String, List<TargetConfig>> get wtMap =>
      throw _privateConstructorUsedError;
  Map<String, List<TargetConfig>> get playListMap =>
      throw _privateConstructorUsedError;
  Map<String, bool> get suspendedMap => throw _privateConstructorUsedError;
  Map<String, int> get selectedTargetIndexMap =>
      throw _privateConstructorUsedError; // current selection
  TargetConfig? get targetPlaying =>
      throw _privateConstructorUsedError; // TargetConfig? lastUpdatedTC, // for debug only
  int get force => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CAPIStateCopyWith<CAPIState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CAPIStateCopyWith<$Res> {
  factory $CAPIStateCopyWith(CAPIState value, $Res Function(CAPIState) then) =
      _$CAPIStateCopyWithImpl<$Res, CAPIState>;
  @useResult
  $Res call(
      {bool localTestingFilePaths,
      Map<String, List<TargetConfig>> wtMap,
      Map<String, List<TargetConfig>> playListMap,
      Map<String, bool> suspendedMap,
      Map<String, int> selectedTargetIndexMap,
      TargetConfig? targetPlaying,
      int force});
}

/// @nodoc
class _$CAPIStateCopyWithImpl<$Res, $Val extends CAPIState>
    implements $CAPIStateCopyWith<$Res> {
  _$CAPIStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localTestingFilePaths = null,
    Object? wtMap = null,
    Object? playListMap = null,
    Object? suspendedMap = null,
    Object? selectedTargetIndexMap = null,
    Object? targetPlaying = freezed,
    Object? force = null,
  }) {
    return _then(_value.copyWith(
      localTestingFilePaths: null == localTestingFilePaths
          ? _value.localTestingFilePaths
          : localTestingFilePaths // ignore: cast_nullable_to_non_nullable
              as bool,
      wtMap: null == wtMap
          ? _value.wtMap
          : wtMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<TargetConfig>>,
      playListMap: null == playListMap
          ? _value.playListMap
          : playListMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<TargetConfig>>,
      suspendedMap: null == suspendedMap
          ? _value.suspendedMap
          : suspendedMap // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      selectedTargetIndexMap: null == selectedTargetIndexMap
          ? _value.selectedTargetIndexMap
          : selectedTargetIndexMap // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      targetPlaying: freezed == targetPlaying
          ? _value.targetPlaying
          : targetPlaying // ignore: cast_nullable_to_non_nullable
              as TargetConfig?,
      force: null == force
          ? _value.force
          : force // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CAPIStateCopyWith<$Res> implements $CAPIStateCopyWith<$Res> {
  factory _$$_CAPIStateCopyWith(
          _$_CAPIState value, $Res Function(_$_CAPIState) then) =
      __$$_CAPIStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool localTestingFilePaths,
      Map<String, List<TargetConfig>> wtMap,
      Map<String, List<TargetConfig>> playListMap,
      Map<String, bool> suspendedMap,
      Map<String, int> selectedTargetIndexMap,
      TargetConfig? targetPlaying,
      int force});
}

/// @nodoc
class __$$_CAPIStateCopyWithImpl<$Res>
    extends _$CAPIStateCopyWithImpl<$Res, _$_CAPIState>
    implements _$$_CAPIStateCopyWith<$Res> {
  __$$_CAPIStateCopyWithImpl(
      _$_CAPIState _value, $Res Function(_$_CAPIState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? localTestingFilePaths = null,
    Object? wtMap = null,
    Object? playListMap = null,
    Object? suspendedMap = null,
    Object? selectedTargetIndexMap = null,
    Object? targetPlaying = freezed,
    Object? force = null,
  }) {
    return _then(_$_CAPIState(
      localTestingFilePaths: null == localTestingFilePaths
          ? _value.localTestingFilePaths
          : localTestingFilePaths // ignore: cast_nullable_to_non_nullable
              as bool,
      wtMap: null == wtMap
          ? _value._wtMap
          : wtMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<TargetConfig>>,
      playListMap: null == playListMap
          ? _value._playListMap
          : playListMap // ignore: cast_nullable_to_non_nullable
              as Map<String, List<TargetConfig>>,
      suspendedMap: null == suspendedMap
          ? _value._suspendedMap
          : suspendedMap // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      selectedTargetIndexMap: null == selectedTargetIndexMap
          ? _value._selectedTargetIndexMap
          : selectedTargetIndexMap // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      targetPlaying: freezed == targetPlaying
          ? _value.targetPlaying
          : targetPlaying // ignore: cast_nullable_to_non_nullable
              as TargetConfig?,
      force: null == force
          ? _value.force
          : force // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_CAPIState extends _CAPIState {
  _$_CAPIState(
      {this.localTestingFilePaths = false,
      final Map<String, List<TargetConfig>> wtMap = const {},
      final Map<String, List<TargetConfig>> playListMap = const {},
      final Map<String, bool> suspendedMap = const {},
      final Map<String, int> selectedTargetIndexMap = const {},
      this.targetPlaying,
      this.force = 0})
      : _wtMap = wtMap,
        _playListMap = playListMap,
        _suspendedMap = suspendedMap,
        _selectedTargetIndexMap = selectedTargetIndexMap,
        super._();

  @override
  @JsonKey()
  final bool localTestingFilePaths;
// because filepaths and fonts accedd differently in own package
  final Map<String, List<TargetConfig>> _wtMap;
// because filepaths and fonts accedd differently in own package
  @override
  @JsonKey()
  Map<String, List<TargetConfig>> get wtMap {
    if (_wtMap is EqualUnmodifiableMapView) return _wtMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_wtMap);
  }

  final Map<String, List<TargetConfig>> _playListMap;
  @override
  @JsonKey()
  Map<String, List<TargetConfig>> get playListMap {
    if (_playListMap is EqualUnmodifiableMapView) return _playListMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_playListMap);
  }

  final Map<String, bool> _suspendedMap;
  @override
  @JsonKey()
  Map<String, bool> get suspendedMap {
    if (_suspendedMap is EqualUnmodifiableMapView) return _suspendedMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_suspendedMap);
  }

  final Map<String, int> _selectedTargetIndexMap;
  @override
  @JsonKey()
  Map<String, int> get selectedTargetIndexMap {
    if (_selectedTargetIndexMap is EqualUnmodifiableMapView)
      return _selectedTargetIndexMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_selectedTargetIndexMap);
  }

// current selection
  @override
  final TargetConfig? targetPlaying;
// TargetConfig? lastUpdatedTC, // for debug only
  @override
  @JsonKey()
  final int force;

  @override
  String toString() {
    return 'CAPIState(localTestingFilePaths: $localTestingFilePaths, wtMap: $wtMap, playListMap: $playListMap, suspendedMap: $suspendedMap, selectedTargetIndexMap: $selectedTargetIndexMap, targetPlaying: $targetPlaying, force: $force)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CAPIState &&
            (identical(other.localTestingFilePaths, localTestingFilePaths) ||
                other.localTestingFilePaths == localTestingFilePaths) &&
            const DeepCollectionEquality().equals(other._wtMap, _wtMap) &&
            const DeepCollectionEquality()
                .equals(other._playListMap, _playListMap) &&
            const DeepCollectionEquality()
                .equals(other._suspendedMap, _suspendedMap) &&
            const DeepCollectionEquality().equals(
                other._selectedTargetIndexMap, _selectedTargetIndexMap) &&
            (identical(other.targetPlaying, targetPlaying) ||
                other.targetPlaying == targetPlaying) &&
            (identical(other.force, force) || other.force == force));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      localTestingFilePaths,
      const DeepCollectionEquality().hash(_wtMap),
      const DeepCollectionEquality().hash(_playListMap),
      const DeepCollectionEquality().hash(_suspendedMap),
      const DeepCollectionEquality().hash(_selectedTargetIndexMap),
      targetPlaying,
      force);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CAPIStateCopyWith<_$_CAPIState> get copyWith =>
      __$$_CAPIStateCopyWithImpl<_$_CAPIState>(this, _$identity);
}

abstract class _CAPIState extends CAPIState {
  factory _CAPIState(
      {final bool localTestingFilePaths,
      final Map<String, List<TargetConfig>> wtMap,
      final Map<String, List<TargetConfig>> playListMap,
      final Map<String, bool> suspendedMap,
      final Map<String, int> selectedTargetIndexMap,
      final TargetConfig? targetPlaying,
      final int force}) = _$_CAPIState;
  _CAPIState._() : super._();

  @override
  bool get localTestingFilePaths;
  @override // because filepaths and fonts accedd differently in own package
  Map<String, List<TargetConfig>> get wtMap;
  @override
  Map<String, List<TargetConfig>> get playListMap;
  @override
  Map<String, bool> get suspendedMap;
  @override
  Map<String, int> get selectedTargetIndexMap;
  @override // current selection
  TargetConfig? get targetPlaying;
  @override // TargetConfig? lastUpdatedTC, // for debug only
  int get force;
  @override
  @JsonKey(ignore: true)
  _$$_CAPIStateCopyWith<_$_CAPIState> get copyWith =>
      throw _privateConstructorUsedError;
}
