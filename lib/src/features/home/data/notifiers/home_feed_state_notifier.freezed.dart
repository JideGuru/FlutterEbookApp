// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_feed_state_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$HomeFeedState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() loadInProgress,
    required TResult Function(CategoryFeed popular, CategoryFeed recent)
        loadSuccess,
    required TResult Function() loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? loadInProgress,
    TResult? Function(CategoryFeed popular, CategoryFeed recent)? loadSuccess,
    TResult? Function()? loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? loadInProgress,
    TResult Function(CategoryFeed popular, CategoryFeed recent)? loadSuccess,
    TResult Function()? loadFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeFeedStateStarted value) started,
    required TResult Function(HomeFeedStateLoadInProgress value) loadInProgress,
    required TResult Function(HomeFeedStateLoadSuccess value) loadSuccess,
    required TResult Function(HomeFeedStateLoadFailure value) loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeFeedStateStarted value)? started,
    TResult? Function(HomeFeedStateLoadInProgress value)? loadInProgress,
    TResult? Function(HomeFeedStateLoadSuccess value)? loadSuccess,
    TResult? Function(HomeFeedStateLoadFailure value)? loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeFeedStateStarted value)? started,
    TResult Function(HomeFeedStateLoadInProgress value)? loadInProgress,
    TResult Function(HomeFeedStateLoadSuccess value)? loadSuccess,
    TResult Function(HomeFeedStateLoadFailure value)? loadFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeFeedStateCopyWith<$Res> {
  factory $HomeFeedStateCopyWith(
          HomeFeedState value, $Res Function(HomeFeedState) then) =
      _$HomeFeedStateCopyWithImpl<$Res, HomeFeedState>;
}

/// @nodoc
class _$HomeFeedStateCopyWithImpl<$Res, $Val extends HomeFeedState>
    implements $HomeFeedStateCopyWith<$Res> {
  _$HomeFeedStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$HomeFeedStateStartedCopyWith<$Res> {
  factory _$$HomeFeedStateStartedCopyWith(_$HomeFeedStateStarted value,
          $Res Function(_$HomeFeedStateStarted) then) =
      __$$HomeFeedStateStartedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$HomeFeedStateStartedCopyWithImpl<$Res>
    extends _$HomeFeedStateCopyWithImpl<$Res, _$HomeFeedStateStarted>
    implements _$$HomeFeedStateStartedCopyWith<$Res> {
  __$$HomeFeedStateStartedCopyWithImpl(_$HomeFeedStateStarted _value,
      $Res Function(_$HomeFeedStateStarted) _then)
      : super(_value, _then);
}

/// @nodoc

class _$HomeFeedStateStarted
    with DiagnosticableTreeMixin
    implements HomeFeedStateStarted {
  const _$HomeFeedStateStarted();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HomeFeedState.started()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'HomeFeedState.started'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$HomeFeedStateStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() loadInProgress,
    required TResult Function(CategoryFeed popular, CategoryFeed recent)
        loadSuccess,
    required TResult Function() loadFailure,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? loadInProgress,
    TResult? Function(CategoryFeed popular, CategoryFeed recent)? loadSuccess,
    TResult? Function()? loadFailure,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? loadInProgress,
    TResult Function(CategoryFeed popular, CategoryFeed recent)? loadSuccess,
    TResult Function()? loadFailure,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeFeedStateStarted value) started,
    required TResult Function(HomeFeedStateLoadInProgress value) loadInProgress,
    required TResult Function(HomeFeedStateLoadSuccess value) loadSuccess,
    required TResult Function(HomeFeedStateLoadFailure value) loadFailure,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeFeedStateStarted value)? started,
    TResult? Function(HomeFeedStateLoadInProgress value)? loadInProgress,
    TResult? Function(HomeFeedStateLoadSuccess value)? loadSuccess,
    TResult? Function(HomeFeedStateLoadFailure value)? loadFailure,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeFeedStateStarted value)? started,
    TResult Function(HomeFeedStateLoadInProgress value)? loadInProgress,
    TResult Function(HomeFeedStateLoadSuccess value)? loadSuccess,
    TResult Function(HomeFeedStateLoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class HomeFeedStateStarted implements HomeFeedState {
  const factory HomeFeedStateStarted() = _$HomeFeedStateStarted;
}

/// @nodoc
abstract class _$$HomeFeedStateLoadInProgressCopyWith<$Res> {
  factory _$$HomeFeedStateLoadInProgressCopyWith(
          _$HomeFeedStateLoadInProgress value,
          $Res Function(_$HomeFeedStateLoadInProgress) then) =
      __$$HomeFeedStateLoadInProgressCopyWithImpl<$Res>;
}

/// @nodoc
class __$$HomeFeedStateLoadInProgressCopyWithImpl<$Res>
    extends _$HomeFeedStateCopyWithImpl<$Res, _$HomeFeedStateLoadInProgress>
    implements _$$HomeFeedStateLoadInProgressCopyWith<$Res> {
  __$$HomeFeedStateLoadInProgressCopyWithImpl(
      _$HomeFeedStateLoadInProgress _value,
      $Res Function(_$HomeFeedStateLoadInProgress) _then)
      : super(_value, _then);
}

/// @nodoc

class _$HomeFeedStateLoadInProgress
    with DiagnosticableTreeMixin
    implements HomeFeedStateLoadInProgress {
  const _$HomeFeedStateLoadInProgress();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HomeFeedState.loadInProgress()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'HomeFeedState.loadInProgress'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeFeedStateLoadInProgress);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() loadInProgress,
    required TResult Function(CategoryFeed popular, CategoryFeed recent)
        loadSuccess,
    required TResult Function() loadFailure,
  }) {
    return loadInProgress();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? loadInProgress,
    TResult? Function(CategoryFeed popular, CategoryFeed recent)? loadSuccess,
    TResult? Function()? loadFailure,
  }) {
    return loadInProgress?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? loadInProgress,
    TResult Function(CategoryFeed popular, CategoryFeed recent)? loadSuccess,
    TResult Function()? loadFailure,
    required TResult orElse(),
  }) {
    if (loadInProgress != null) {
      return loadInProgress();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeFeedStateStarted value) started,
    required TResult Function(HomeFeedStateLoadInProgress value) loadInProgress,
    required TResult Function(HomeFeedStateLoadSuccess value) loadSuccess,
    required TResult Function(HomeFeedStateLoadFailure value) loadFailure,
  }) {
    return loadInProgress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeFeedStateStarted value)? started,
    TResult? Function(HomeFeedStateLoadInProgress value)? loadInProgress,
    TResult? Function(HomeFeedStateLoadSuccess value)? loadSuccess,
    TResult? Function(HomeFeedStateLoadFailure value)? loadFailure,
  }) {
    return loadInProgress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeFeedStateStarted value)? started,
    TResult Function(HomeFeedStateLoadInProgress value)? loadInProgress,
    TResult Function(HomeFeedStateLoadSuccess value)? loadSuccess,
    TResult Function(HomeFeedStateLoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadInProgress != null) {
      return loadInProgress(this);
    }
    return orElse();
  }
}

abstract class HomeFeedStateLoadInProgress implements HomeFeedState {
  const factory HomeFeedStateLoadInProgress() = _$HomeFeedStateLoadInProgress;
}

/// @nodoc
abstract class _$$HomeFeedStateLoadSuccessCopyWith<$Res> {
  factory _$$HomeFeedStateLoadSuccessCopyWith(_$HomeFeedStateLoadSuccess value,
          $Res Function(_$HomeFeedStateLoadSuccess) then) =
      __$$HomeFeedStateLoadSuccessCopyWithImpl<$Res>;
  @useResult
  $Res call({CategoryFeed popular, CategoryFeed recent});
}

/// @nodoc
class __$$HomeFeedStateLoadSuccessCopyWithImpl<$Res>
    extends _$HomeFeedStateCopyWithImpl<$Res, _$HomeFeedStateLoadSuccess>
    implements _$$HomeFeedStateLoadSuccessCopyWith<$Res> {
  __$$HomeFeedStateLoadSuccessCopyWithImpl(_$HomeFeedStateLoadSuccess _value,
      $Res Function(_$HomeFeedStateLoadSuccess) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? popular = null,
    Object? recent = null,
  }) {
    return _then(_$HomeFeedStateLoadSuccess(
      popular: null == popular
          ? _value.popular
          : popular // ignore: cast_nullable_to_non_nullable
              as CategoryFeed,
      recent: null == recent
          ? _value.recent
          : recent // ignore: cast_nullable_to_non_nullable
              as CategoryFeed,
    ));
  }
}

/// @nodoc

class _$HomeFeedStateLoadSuccess
    with DiagnosticableTreeMixin
    implements HomeFeedStateLoadSuccess {
  const _$HomeFeedStateLoadSuccess(
      {required this.popular, required this.recent});

  @override
  final CategoryFeed popular;
  @override
  final CategoryFeed recent;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HomeFeedState.loadSuccess(popular: $popular, recent: $recent)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'HomeFeedState.loadSuccess'))
      ..add(DiagnosticsProperty('popular', popular))
      ..add(DiagnosticsProperty('recent', recent));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeFeedStateLoadSuccess &&
            (identical(other.popular, popular) || other.popular == popular) &&
            (identical(other.recent, recent) || other.recent == recent));
  }

  @override
  int get hashCode => Object.hash(runtimeType, popular, recent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeFeedStateLoadSuccessCopyWith<_$HomeFeedStateLoadSuccess>
      get copyWith =>
          __$$HomeFeedStateLoadSuccessCopyWithImpl<_$HomeFeedStateLoadSuccess>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() loadInProgress,
    required TResult Function(CategoryFeed popular, CategoryFeed recent)
        loadSuccess,
    required TResult Function() loadFailure,
  }) {
    return loadSuccess(popular, recent);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? loadInProgress,
    TResult? Function(CategoryFeed popular, CategoryFeed recent)? loadSuccess,
    TResult? Function()? loadFailure,
  }) {
    return loadSuccess?.call(popular, recent);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? loadInProgress,
    TResult Function(CategoryFeed popular, CategoryFeed recent)? loadSuccess,
    TResult Function()? loadFailure,
    required TResult orElse(),
  }) {
    if (loadSuccess != null) {
      return loadSuccess(popular, recent);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeFeedStateStarted value) started,
    required TResult Function(HomeFeedStateLoadInProgress value) loadInProgress,
    required TResult Function(HomeFeedStateLoadSuccess value) loadSuccess,
    required TResult Function(HomeFeedStateLoadFailure value) loadFailure,
  }) {
    return loadSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeFeedStateStarted value)? started,
    TResult? Function(HomeFeedStateLoadInProgress value)? loadInProgress,
    TResult? Function(HomeFeedStateLoadSuccess value)? loadSuccess,
    TResult? Function(HomeFeedStateLoadFailure value)? loadFailure,
  }) {
    return loadSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeFeedStateStarted value)? started,
    TResult Function(HomeFeedStateLoadInProgress value)? loadInProgress,
    TResult Function(HomeFeedStateLoadSuccess value)? loadSuccess,
    TResult Function(HomeFeedStateLoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadSuccess != null) {
      return loadSuccess(this);
    }
    return orElse();
  }
}

abstract class HomeFeedStateLoadSuccess implements HomeFeedState {
  const factory HomeFeedStateLoadSuccess(
      {required final CategoryFeed popular,
      required final CategoryFeed recent}) = _$HomeFeedStateLoadSuccess;

  CategoryFeed get popular;
  CategoryFeed get recent;
  @JsonKey(ignore: true)
  _$$HomeFeedStateLoadSuccessCopyWith<_$HomeFeedStateLoadSuccess>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$HomeFeedStateLoadFailureCopyWith<$Res> {
  factory _$$HomeFeedStateLoadFailureCopyWith(_$HomeFeedStateLoadFailure value,
          $Res Function(_$HomeFeedStateLoadFailure) then) =
      __$$HomeFeedStateLoadFailureCopyWithImpl<$Res>;
}

/// @nodoc
class __$$HomeFeedStateLoadFailureCopyWithImpl<$Res>
    extends _$HomeFeedStateCopyWithImpl<$Res, _$HomeFeedStateLoadFailure>
    implements _$$HomeFeedStateLoadFailureCopyWith<$Res> {
  __$$HomeFeedStateLoadFailureCopyWithImpl(_$HomeFeedStateLoadFailure _value,
      $Res Function(_$HomeFeedStateLoadFailure) _then)
      : super(_value, _then);
}

/// @nodoc

class _$HomeFeedStateLoadFailure
    with DiagnosticableTreeMixin
    implements HomeFeedStateLoadFailure {
  const _$HomeFeedStateLoadFailure();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HomeFeedState.loadFailure()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'HomeFeedState.loadFailure'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeFeedStateLoadFailure);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() loadInProgress,
    required TResult Function(CategoryFeed popular, CategoryFeed recent)
        loadSuccess,
    required TResult Function() loadFailure,
  }) {
    return loadFailure();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? loadInProgress,
    TResult? Function(CategoryFeed popular, CategoryFeed recent)? loadSuccess,
    TResult? Function()? loadFailure,
  }) {
    return loadFailure?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? loadInProgress,
    TResult Function(CategoryFeed popular, CategoryFeed recent)? loadSuccess,
    TResult Function()? loadFailure,
    required TResult orElse(),
  }) {
    if (loadFailure != null) {
      return loadFailure();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeFeedStateStarted value) started,
    required TResult Function(HomeFeedStateLoadInProgress value) loadInProgress,
    required TResult Function(HomeFeedStateLoadSuccess value) loadSuccess,
    required TResult Function(HomeFeedStateLoadFailure value) loadFailure,
  }) {
    return loadFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeFeedStateStarted value)? started,
    TResult? Function(HomeFeedStateLoadInProgress value)? loadInProgress,
    TResult? Function(HomeFeedStateLoadSuccess value)? loadSuccess,
    TResult? Function(HomeFeedStateLoadFailure value)? loadFailure,
  }) {
    return loadFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeFeedStateStarted value)? started,
    TResult Function(HomeFeedStateLoadInProgress value)? loadInProgress,
    TResult Function(HomeFeedStateLoadSuccess value)? loadSuccess,
    TResult Function(HomeFeedStateLoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadFailure != null) {
      return loadFailure(this);
    }
    return orElse();
  }
}

abstract class HomeFeedStateLoadFailure implements HomeFeedState {
  const factory HomeFeedStateLoadFailure() = _$HomeFeedStateLoadFailure;
}
