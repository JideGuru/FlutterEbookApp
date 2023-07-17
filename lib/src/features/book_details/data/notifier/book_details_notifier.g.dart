// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_details_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookDetailsNotifierHash() =>
    r'0e8d835073df2c1de5aefb6f0437005ebef67290';

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

abstract class _$BookDetailsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CategoryFeed> {
  late final String url;

  Future<CategoryFeed> build(
    String url,
  );
}

/// See also [BookDetailsNotifier].
@ProviderFor(BookDetailsNotifier)
const bookDetailsNotifierProvider = BookDetailsNotifierFamily();

/// See also [BookDetailsNotifier].
class BookDetailsNotifierFamily extends Family<AsyncValue<CategoryFeed>> {
  /// See also [BookDetailsNotifier].
  const BookDetailsNotifierFamily();

  /// See also [BookDetailsNotifier].
  BookDetailsNotifierProvider call(
    String url,
  ) {
    return BookDetailsNotifierProvider(
      url,
    );
  }

  @override
  BookDetailsNotifierProvider getProviderOverride(
    covariant BookDetailsNotifierProvider provider,
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
  String? get name => r'bookDetailsNotifierProvider';
}

/// See also [BookDetailsNotifier].
class BookDetailsNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    BookDetailsNotifier, CategoryFeed> {
  /// See also [BookDetailsNotifier].
  BookDetailsNotifierProvider(
    this.url,
  ) : super.internal(
          () => BookDetailsNotifier()..url = url,
          from: bookDetailsNotifierProvider,
          name: r'bookDetailsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookDetailsNotifierHash,
          dependencies: BookDetailsNotifierFamily._dependencies,
          allTransitiveDependencies:
              BookDetailsNotifierFamily._allTransitiveDependencies,
        );

  final String url;

  @override
  bool operator ==(Object other) {
    return other is BookDetailsNotifierProvider && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }

  @override
  Future<CategoryFeed> runNotifierBuild(
    covariant BookDetailsNotifier notifier,
  ) {
    return notifier.build(
      url,
    );
  }
}
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
