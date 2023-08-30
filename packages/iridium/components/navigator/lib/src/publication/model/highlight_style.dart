import 'package:dartx/dartx.dart';

class HighlightStyle {
  static const HighlightStyle highlight = HighlightStyle._(0, "highlight");
  static const HighlightStyle underline = HighlightStyle._(1, "underline");

  static const List<HighlightStyle> values = [
    highlight,
    underline,
  ];
  final int id;
  final String value;

  const HighlightStyle._(this.id, this.value);

  static HighlightStyle? from(int? id) =>
      values.firstOrNullWhere((type) => type.id == id);

  @override
  String toString() => '$runtimeType{id: $id, value: $value}';
}
