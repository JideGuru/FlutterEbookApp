// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_details_state_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$BookDetailsState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() loadInProgress,
    required TResult Function(CategoryFeed related) loadSuccess,
    required TResult Function() loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? loadInProgress,
    TResult? Function(CategoryFeed related)? loadSuccess,
    TResult? Function()? loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? loadInProgress,
    TResult Function(CategoryFeed related)? loadSuccess,
    TResult Function()? loadFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BookDetailsStateStarted value) started,
    required TResult Function(BookDetailsStateLoadInProgress value)
        loadInProgress,
    required TResult Function(BookDetailsStateLoadSuccess value) loadSuccess,
    required TResult Function(BookDetailsStateLoadFailure value) loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BookDetailsStateStarted value)? started,
    TResult? Function(BookDetailsStateLoadInProgress value)? loadInProgress,
    TResult? Function(BookDetailsStateLoadSuccess value)? loadSuccess,
    TResult? Function(BookDetailsStateLoadFailure value)? loadFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BookDetailsStateStarted value)? started,
    TResult Function(BookDetailsStateLoadInProgress value)? loadInProgress,
    TResult Function(BookDetailsStateLoadSuccess value)? loadSuccess,
    TResult Function(BookDetailsStateLoadFailure value)? loadFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookDetailsStateCopyWith<$Res> {
  factory $BookDetailsStateCopyWith(
          BookDetailsState value, $Res Function(BookDetailsState) then) =
      _$BookDetailsStateCopyWithImpl<$Res, BookDetailsState>;
}

/// @nodoc
class _$BookDetailsStateCopyWithImpl<$Res, $Val extends BookDetailsState>
    implements $BookDetailsStateCopyWith<$Res> {
  _$BookDetailsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$BookDetailsStateStartedCopyWith<$Res> {
  factory _$$BookDetailsStateStartedCopyWith(_$BookDetailsStateStarted value,
          $Res Function(_$BookDetailsStateStarted) then) =
      __$$BookDetailsStateStartedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BookDetailsStateStartedCopyWithImpl<$Res>
    extends _$BookDetailsStateCopyWithImpl<$Res, _$BookDetailsStateStarted>
    implements _$$BookDetailsStateStartedCopyWith<$Res> {
  __$$BookDetailsStateStartedCopyWithImpl(_$BookDetailsStateStarted _value,
      $Res Function(_$BookDetailsStateStarted) _then)
      : super(_value, _then);
}

/// @nodoc

class _$BookDetailsStateStarted implements BookDetailsStateStarted {
  const _$BookDetailsStateStarted();

  @override
  String toString() {
    return 'BookDetailsState.started()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookDetailsStateStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() loadInProgress,
    required TResult Function(CategoryFeed related) loadSuccess,
    required TResult Function() loadFailure,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? loadInProgress,
    TResult? Function(CategoryFeed related)? loadSuccess,
    TResult? Function()? loadFailure,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? loadInProgress,
    TResult Function(CategoryFeed related)? loadSuccess,
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
    required TResult Function(BookDetailsStateStarted value) started,
    required TResult Function(BookDetailsStateLoadInProgress value)
        loadInProgress,
    required TResult Function(BookDetailsStateLoadSuccess value) loadSuccess,
    required TResult Function(BookDetailsStateLoadFailure value) loadFailure,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BookDetailsStateStarted value)? started,
    TResult? Function(BookDetailsStateLoadInProgress value)? loadInProgress,
    TResult? Function(BookDetailsStateLoadSuccess value)? loadSuccess,
    TResult? Function(BookDetailsStateLoadFailure value)? loadFailure,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BookDetailsStateStarted value)? started,
    TResult Function(BookDetailsStateLoadInProgress value)? loadInProgress,
    TResult Function(BookDetailsStateLoadSuccess value)? loadSuccess,
    TResult Function(BookDetailsStateLoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class BookDetailsStateStarted implements BookDetailsState {
  const factory BookDetailsStateStarted() = _$BookDetailsStateStarted;
}

/// @nodoc
abstract class _$$BookDetailsStateLoadInProgressCopyWith<$Res> {
  factory _$$BookDetailsStateLoadInProgressCopyWith(
          _$BookDetailsStateLoadInProgress value,
          $Res Function(_$BookDetailsStateLoadInProgress) then) =
      __$$BookDetailsStateLoadInProgressCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BookDetailsStateLoadInProgressCopyWithImpl<$Res>
    extends _$BookDetailsStateCopyWithImpl<$Res,
        _$BookDetailsStateLoadInProgress>
    implements _$$BookDetailsStateLoadInProgressCopyWith<$Res> {
  __$$BookDetailsStateLoadInProgressCopyWithImpl(
      _$BookDetailsStateLoadInProgress _value,
      $Res Function(_$BookDetailsStateLoadInProgress) _then)
      : super(_value, _then);
}

/// @nodoc

class _$BookDetailsStateLoadInProgress
    implements BookDetailsStateLoadInProgress {
  const _$BookDetailsStateLoadInProgress();

  @override
  String toString() {
    return 'BookDetailsState.loadInProgress()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookDetailsStateLoadInProgress);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() loadInProgress,
    required TResult Function(CategoryFeed related) loadSuccess,
    required TResult Function() loadFailure,
  }) {
    return loadInProgress();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? loadInProgress,
    TResult? Function(CategoryFeed related)? loadSuccess,
    TResult? Function()? loadFailure,
  }) {
    return loadInProgress?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? loadInProgress,
    TResult Function(CategoryFeed related)? loadSuccess,
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
    required TResult Function(BookDetailsStateStarted value) started,
    required TResult Function(BookDetailsStateLoadInProgress value)
        loadInProgress,
    required TResult Function(BookDetailsStateLoadSuccess value) loadSuccess,
    required TResult Function(BookDetailsStateLoadFailure value) loadFailure,
  }) {
    return loadInProgress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BookDetailsStateStarted value)? started,
    TResult? Function(BookDetailsStateLoadInProgress value)? loadInProgress,
    TResult? Function(BookDetailsStateLoadSuccess value)? loadSuccess,
    TResult? Function(BookDetailsStateLoadFailure value)? loadFailure,
  }) {
    return loadInProgress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BookDetailsStateStarted value)? started,
    TResult Function(BookDetailsStateLoadInProgress value)? loadInProgress,
    TResult Function(BookDetailsStateLoadSuccess value)? loadSuccess,
    TResult Function(BookDetailsStateLoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadInProgress != null) {
      return loadInProgress(this);
    }
    return orElse();
  }
}

abstract class BookDetailsStateLoadInProgress implements BookDetailsState {
  const factory BookDetailsStateLoadInProgress() =
      _$BookDetailsStateLoadInProgress;
}

/// @nodoc
abstract class _$$BookDetailsStateLoadSuccessCopyWith<$Res> {
  factory _$$BookDetailsStateLoadSuccessCopyWith(
          _$BookDetailsStateLoadSuccess value,
          $Res Function(_$BookDetailsStateLoadSuccess) then) =
      __$$BookDetailsStateLoadSuccessCopyWithImpl<$Res>;
  @useResult
  $Res call({CategoryFeed related});
}

/// @nodoc
class __$$BookDetailsStateLoadSuccessCopyWithImpl<$Res>
    extends _$BookDetailsStateCopyWithImpl<$Res, _$BookDetailsStateLoadSuccess>
    implements _$$BookDetailsStateLoadSuccessCopyWith<$Res> {
  __$$BookDetailsStateLoadSuccessCopyWithImpl(
      _$BookDetailsStateLoadSuccess _value,
      $Res Function(_$BookDetailsStateLoadSuccess) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? related = null,
  }) {
    return _then(_$BookDetailsStateLoadSuccess(
      related: null == related
          ? _value.related
          : related // ignore: cast_nullable_to_non_nullable
              as CategoryFeed,
    ));
  }
}

/// @nodoc

class _$BookDetailsStateLoadSuccess implements BookDetailsStateLoadSuccess {
  const _$BookDetailsStateLoadSuccess({required this.related});

  @override
  final CategoryFeed related;

  @override
  String toString() {
    return 'BookDetailsState.loadSuccess(related: $related)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookDetailsStateLoadSuccess &&
            (identical(other.related, related) || other.related == related));
  }

  @override
  int get hashCode => Object.hash(runtimeType, related);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookDetailsStateLoadSuccessCopyWith<_$BookDetailsStateLoadSuccess>
      get copyWith => __$$BookDetailsStateLoadSuccessCopyWithImpl<
          _$BookDetailsStateLoadSuccess>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() loadInProgress,
    required TResult Function(CategoryFeed related) loadSuccess,
    required TResult Function() loadFailure,
  }) {
    return loadSuccess(related);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? loadInProgress,
    TResult? Function(CategoryFeed related)? loadSuccess,
    TResult? Function()? loadFailure,
  }) {
    return loadSuccess?.call(related);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? loadInProgress,
    TResult Function(CategoryFeed related)? loadSuccess,
    TResult Function()? loadFailure,
    required TResult orElse(),
  }) {
    if (loadSuccess != null) {
      return loadSuccess(related);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BookDetailsStateStarted value) started,
    required TResult Function(BookDetailsStateLoadInProgress value)
        loadInProgress,
    required TResult Function(BookDetailsStateLoadSuccess value) loadSuccess,
    required TResult Function(BookDetailsStateLoadFailure value) loadFailure,
  }) {
    return loadSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BookDetailsStateStarted value)? started,
    TResult? Function(BookDetailsStateLoadInProgress value)? loadInProgress,
    TResult? Function(BookDetailsStateLoadSuccess value)? loadSuccess,
    TResult? Function(BookDetailsStateLoadFailure value)? loadFailure,
  }) {
    return loadSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BookDetailsStateStarted value)? started,
    TResult Function(BookDetailsStateLoadInProgress value)? loadInProgress,
    TResult Function(BookDetailsStateLoadSuccess value)? loadSuccess,
    TResult Function(BookDetailsStateLoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadSuccess != null) {
      return loadSuccess(this);
    }
    return orElse();
  }
}

abstract class BookDetailsStateLoadSuccess implements BookDetailsState {
  const factory BookDetailsStateLoadSuccess(
      {required final CategoryFeed related}) = _$BookDetailsStateLoadSuccess;

  CategoryFeed get related;
  @JsonKey(ignore: true)
  _$$BookDetailsStateLoadSuccessCopyWith<_$BookDetailsStateLoadSuccess>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BookDetailsStateLoadFailureCopyWith<$Res> {
  factory _$$BookDetailsStateLoadFailureCopyWith(
          _$BookDetailsStateLoadFailure value,
          $Res Function(_$BookDetailsStateLoadFailure) then) =
      __$$BookDetailsStateLoadFailureCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BookDetailsStateLoadFailureCopyWithImpl<$Res>
    extends _$BookDetailsStateCopyWithImpl<$Res, _$BookDetailsStateLoadFailure>
    implements _$$BookDetailsStateLoadFailureCopyWith<$Res> {
  __$$BookDetailsStateLoadFailureCopyWithImpl(
      _$BookDetailsStateLoadFailure _value,
      $Res Function(_$BookDetailsStateLoadFailure) _then)
      : super(_value, _then);
}

/// @nodoc

class _$BookDetailsStateLoadFailure implements BookDetailsStateLoadFailure {
  const _$BookDetailsStateLoadFailure();

  @override
  String toString() {
    return 'BookDetailsState.loadFailure()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookDetailsStateLoadFailure);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() loadInProgress,
    required TResult Function(CategoryFeed related) loadSuccess,
    required TResult Function() loadFailure,
  }) {
    return loadFailure();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? loadInProgress,
    TResult? Function(CategoryFeed related)? loadSuccess,
    TResult? Function()? loadFailure,
  }) {
    return loadFailure?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? loadInProgress,
    TResult Function(CategoryFeed related)? loadSuccess,
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
    required TResult Function(BookDetailsStateStarted value) started,
    required TResult Function(BookDetailsStateLoadInProgress value)
        loadInProgress,
    required TResult Function(BookDetailsStateLoadSuccess value) loadSuccess,
    required TResult Function(BookDetailsStateLoadFailure value) loadFailure,
  }) {
    return loadFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BookDetailsStateStarted value)? started,
    TResult? Function(BookDetailsStateLoadInProgress value)? loadInProgress,
    TResult? Function(BookDetailsStateLoadSuccess value)? loadSuccess,
    TResult? Function(BookDetailsStateLoadFailure value)? loadFailure,
  }) {
    return loadFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BookDetailsStateStarted value)? started,
    TResult Function(BookDetailsStateLoadInProgress value)? loadInProgress,
    TResult Function(BookDetailsStateLoadSuccess value)? loadSuccess,
    TResult Function(BookDetailsStateLoadFailure value)? loadFailure,
    required TResult orElse(),
  }) {
    if (loadFailure != null) {
      return loadFailure(this);
    }
    return orElse();
  }
}

abstract class BookDetailsStateLoadFailure implements BookDetailsState {
  const factory BookDetailsStateLoadFailure() = _$BookDetailsStateLoadFailure;
}
