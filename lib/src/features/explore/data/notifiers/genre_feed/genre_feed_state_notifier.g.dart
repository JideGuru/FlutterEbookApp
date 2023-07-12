// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre_feed_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$genreFeedStateNotifierHash() =>
    r'0bfde7f0465daf5b9fd95dce164b88dcef2d496f';

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

abstract class _$GenreFeedStateNotifier
    extends BuildlessAutoDisposeAsyncNotifier<(List<Entry>, bool)> {
  late final String url;

  Future<(List<Entry>, bool)> build(
    String url,
  );
}

/// See also [GenreFeedStateNotifier].
@ProviderFor(GenreFeedStateNotifier)
const genreFeedStateNotifierProvider = GenreFeedStateNotifierFamily();

/// See also [GenreFeedStateNotifier].
class GenreFeedStateNotifierFamily
    extends Family<AsyncValue<(List<Entry>, bool)>> {
  /// See also [GenreFeedStateNotifier].
  const GenreFeedStateNotifierFamily();

  /// See also [GenreFeedStateNotifier].
  GenreFeedStateNotifierProvider call(
    String url,
  ) {
    return GenreFeedStateNotifierProvider(
      url,
    );
  }

  @override
  GenreFeedStateNotifierProvider getProviderOverride(
    covariant GenreFeedStateNotifierProvider provider,
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
  String? get name => r'genreFeedStateNotifierProvider';
}

/// See also [GenreFeedStateNotifier].
class GenreFeedStateNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<GenreFeedStateNotifier,
        (List<Entry>, bool)> {
  /// See also [GenreFeedStateNotifier].
  GenreFeedStateNotifierProvider(
    this.url,
  ) : super.internal(
          () => GenreFeedStateNotifier()..url = url,
          from: genreFeedStateNotifierProvider,
          name: r'genreFeedStateNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$genreFeedStateNotifierHash,
          dependencies: GenreFeedStateNotifierFamily._dependencies,
          allTransitiveDependencies:
              GenreFeedStateNotifierFamily._allTransitiveDependencies,
        );

  final String url;

  @override
  bool operator ==(Object other) {
    return other is GenreFeedStateNotifierProvider && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }

  @override
  Future<(List<Entry>, bool)> runNotifierBuild(
    covariant GenreFeedStateNotifier notifier,
  ) {
    return notifier.build(
      url,
    );
  }
}
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
