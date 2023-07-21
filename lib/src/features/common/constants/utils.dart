import 'dart:math';

String formatBytes(int bytes, int decimals) {
  if (bytes == 0) return '0.0';
  const k = 1024;
  final dm = decimals <= 0 ? 0 : decimals;
  final sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  final i = (log(bytes) / log(k)).floor();
  return '${(bytes / pow(k, i)).toStringAsFixed(dm)} ${sizes[i]}';
}
