// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre_feed_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$genreFeedNotifierHash() => r'7a69bc3de097b979c3a8d3f2cd5fe066e031f9ec';

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

abstract class _$GenreFeedNotifier
    extends BuildlessAutoDisposeAsyncNotifier<(List<Entry>, bool)> {
  late final String url;

  Future<(List<Entry>, bool)> build(
    String url,
  );
}

/// See also [GenreFeedNotifier].
@ProviderFor(GenreFeedNotifier)
const genreFeedNotifierProvider = GenreFeedNotifierFamily();

/// See also [GenreFeedNotifier].
class GenreFeedNotifierFamily extends Family<AsyncValue<(List<Entry>, bool)>> {
  /// See also [GenreFeedNotifier].
  const GenreFeedNotifierFamily();

  /// See also [GenreFeedNotifier].
  GenreFeedNotifierProvider call(
    String url,
  ) {
    return GenreFeedNotifierProvider(
      url,
    );
  }

  @override
  GenreFeedNotifierProvider getProviderOverride(
    covariant GenreFeedNotifierProvider provider,
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
  String? get name => r'genreFeedNotifierProvider';
}

/// See also [GenreFeedNotifier].
class GenreFeedNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    GenreFeedNotifier, (List<Entry>, bool)> {
  /// See also [GenreFeedNotifier].
  GenreFeedNotifierProvider(
    this.url,
  ) : super.internal(
          () => GenreFeedNotifier()..url = url,
          from: genreFeedNotifierProvider,
          name: r'genreFeedNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$genreFeedNotifierHash,
          dependencies: GenreFeedNotifierFamily._dependencies,
          allTransitiveDependencies:
              GenreFeedNotifierFamily._allTransitiveDependencies,
        );

  final String url;

  @override
  bool operator ==(Object other) {
    return other is GenreFeedNotifierProvider && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }

  @override
  Future<(List<Entry>, bool)> runNotifierBuild(
    covariant GenreFeedNotifier notifier,
  ) {
    return notifier.build(
      url,
    );
  }
}
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
