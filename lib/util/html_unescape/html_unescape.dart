import 'base.dart';
import 'named_chars_all.dart' as data;

class HtmlUnescape extends HtmlUnescapeBase {
  final int maxKeyLength = data.maxKeyLength;
  final List<String> keys = data.keys;
  final List<String> values = data.values;
}