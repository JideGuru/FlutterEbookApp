// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorites_state_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$FavoritesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(List<Entry> favorites) listening,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(List<Entry> favorites)? listening,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(List<Entry> favorites)? listening,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FavoritesStateStarted value) started,
    required TResult Function(FavoritesStateLoadListening value) listening,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FavoritesStateStarted value)? started,
    TResult? Function(FavoritesStateLoadListening value)? listening,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FavoritesStateStarted value)? started,
    TResult Function(FavoritesStateLoadListening value)? listening,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoritesStateCopyWith<$Res> {
  factory $FavoritesStateCopyWith(
          FavoritesState value, $Res Function(FavoritesState) then) =
      _$FavoritesStateCopyWithImpl<$Res, FavoritesState>;
}

/// @nodoc
class _$FavoritesStateCopyWithImpl<$Res, $Val extends FavoritesState>
    implements $FavoritesStateCopyWith<$Res> {
  _$FavoritesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$FavoritesStateStartedCopyWith<$Res> {
  factory _$$FavoritesStateStartedCopyWith(_$FavoritesStateStarted value,
          $Res Function(_$FavoritesStateStarted) then) =
      __$$FavoritesStateStartedCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FavoritesStateStartedCopyWithImpl<$Res>
    extends _$FavoritesStateCopyWithImpl<$Res, _$FavoritesStateStarted>
    implements _$$FavoritesStateStartedCopyWith<$Res> {
  __$$FavoritesStateStartedCopyWithImpl(_$FavoritesStateStarted _value,
      $Res Function(_$FavoritesStateStarted) _then)
      : super(_value, _then);
}

/// @nodoc

class _$FavoritesStateStarted implements FavoritesStateStarted {
  const _$FavoritesStateStarted();

  @override
  String toString() {
    return 'FavoritesState.started()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FavoritesStateStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(List<Entry> favorites) listening,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(List<Entry> favorites)? listening,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(List<Entry> favorites)? listening,
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
    required TResult Function(FavoritesStateStarted value) started,
    required TResult Function(FavoritesStateLoadListening value) listening,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FavoritesStateStarted value)? started,
    TResult? Function(FavoritesStateLoadListening value)? listening,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FavoritesStateStarted value)? started,
    TResult Function(FavoritesStateLoadListening value)? listening,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class FavoritesStateStarted implements FavoritesState {
  const factory FavoritesStateStarted() = _$FavoritesStateStarted;
}

/// @nodoc
abstract class _$$FavoritesStateLoadListeningCopyWith<$Res> {
  factory _$$FavoritesStateLoadListeningCopyWith(
          _$FavoritesStateLoadListening value,
          $Res Function(_$FavoritesStateLoadListening) then) =
      __$$FavoritesStateLoadListeningCopyWithImpl<$Res>;
  @useResult
  $Res call({List<Entry> favorites});
}

/// @nodoc
class __$$FavoritesStateLoadListeningCopyWithImpl<$Res>
    extends _$FavoritesStateCopyWithImpl<$Res, _$FavoritesStateLoadListening>
    implements _$$FavoritesStateLoadListeningCopyWith<$Res> {
  __$$FavoritesStateLoadListeningCopyWithImpl(
      _$FavoritesStateLoadListening _value,
      $Res Function(_$FavoritesStateLoadListening) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? favorites = null,
  }) {
    return _then(_$FavoritesStateLoadListening(
      favorites: null == favorites
          ? _value._favorites
          : favorites // ignore: cast_nullable_to_non_nullable
              as List<Entry>,
    ));
  }
}

/// @nodoc

class _$FavoritesStateLoadListening implements FavoritesStateLoadListening {
  const _$FavoritesStateLoadListening({required final List<Entry> favorites})
      : _favorites = favorites;

  final List<Entry> _favorites;
  @override
  List<Entry> get favorites {
    if (_favorites is EqualUnmodifiableListView) return _favorites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favorites);
  }

  @override
  String toString() {
    return 'FavoritesState.listening(favorites: $favorites)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FavoritesStateLoadListening &&
            const DeepCollectionEquality()
                .equals(other._favorites, _favorites));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_favorites));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FavoritesStateLoadListeningCopyWith<_$FavoritesStateLoadListening>
      get copyWith => __$$FavoritesStateLoadListeningCopyWithImpl<
          _$FavoritesStateLoadListening>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(List<Entry> favorites) listening,
  }) {
    return listening(favorites);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(List<Entry> favorites)? listening,
  }) {
    return listening?.call(favorites);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(List<Entry> favorites)? listening,
    required TResult orElse(),
  }) {
    if (listening != null) {
      return listening(favorites);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FavoritesStateStarted value) started,
    required TResult Function(FavoritesStateLoadListening value) listening,
  }) {
    return listening(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FavoritesStateStarted value)? started,
    TResult? Function(FavoritesStateLoadListening value)? listening,
  }) {
    return listening?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FavoritesStateStarted value)? started,
    TResult Function(FavoritesStateLoadListening value)? listening,
    required TResult orElse(),
  }) {
    if (listening != null) {
      return listening(this);
    }
    return orElse();
  }
}

abstract class FavoritesStateLoadListening implements FavoritesState {
  const factory FavoritesStateLoadListening(
      {required final List<Entry> favorites}) = _$FavoritesStateLoadListening;

  List<Entry> get favorites;
  @JsonKey(ignore: true)
  _$$FavoritesStateLoadListeningCopyWith<_$FavoritesStateLoadListening>
      get copyWith => throw _privateConstructorUsedError;
}
