import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logman/logman.dart';

class RiverpodObserver extends ProviderObserver {
  final logman = Logman.instance;

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    logman.info('Provider $provider was initialized with $value');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    logman.info('Provider $provider was disposed');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    logman.info(
      'Provider $provider updated from $previousValue to $newValue',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    logman.info('Provider $provider threw $error at $stackTrace');
  }
}
