// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_details_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookDetailsStateNotifierHash() =>
    r'753c3a09dd894efa0cf3122935d4856fb30b12eb';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$BookDetailsStateNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CategoryFeed> {
  late final String url;

  Future<CategoryFeed> build(
    String url,
  );
}

/// See also [BookDetailsStateNotifier].
@ProviderFor(BookDetailsStateNotifier)
const bookDetailsStateNotifierProvider = BookDetailsStateNotifierFamily();

/// See also [BookDetailsStateNotifier].
class BookDetailsStateNotifierFamily extends Family<AsyncValue<CategoryFeed>> {
  /// See also [BookDetailsStateNotifier].
  const BookDetailsStateNotifierFamily();

  /// See also [BookDetailsStateNotifier].
  BookDetailsStateNotifierProvider call(
    String url,
  ) {
    return BookDetailsStateNotifierProvider(
      url,
    );
  }

  @override
  BookDetailsStateNotifierProvider getProviderOverride(
    covariant BookDetailsStateNotifierProvider provider,
  ) {
    return call(
      provider.url,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookDetailsStateNotifierProvider';
}

/// See also [BookDetailsStateNotifier].
class BookDetailsStateNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<BookDetailsStateNotifier,
        CategoryFeed> {
  /// See also [BookDetailsStateNotifier].
  BookDetailsStateNotifierProvider(
    this.url,
  ) : super.internal(
          () => BookDetailsStateNotifier()..url = url,
          from: bookDetailsStateNotifierProvider,
          name: r'bookDetailsStateNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookDetailsStateNotifierHash,
          dependencies: BookDetailsStateNotifierFamily._dependencies,
          allTransitiveDependencies:
              BookDetailsStateNotifierFamily._allTransitiveDependencies,
        );

  final String url;

  @override
  bool operator ==(Object other) {
    return other is BookDetailsStateNotifierProvider && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }

  @override
  Future<CategoryFeed> runNotifierBuild(
    covariant BookDetailsStateNotifier notifier,
  ) {
    return notifier.build(
      url,
    );
  }
}
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
