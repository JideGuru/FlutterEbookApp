part of 'downloads_state_notifier.dart';

@freezed
abstract class DownloadsState with _$DownloadsState {
  const factory DownloadsState.started() = DownloadsStateStarted;

  const factory DownloadsState.listening({
    required List<Map<String, dynamic>> downloads,
  }) = DownloadsStateLoadListening;
}
