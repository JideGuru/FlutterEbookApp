class Injectable {
  static const Injectable script = Injectable("scripts");
  static const Injectable font = Injectable("fonts");
  static const Injectable style = Injectable("styles");
  static const List<Injectable> values = [script, font, style];
  final String rawValue;

  const Injectable(this.rawValue);

  @override
  String toString() => rawValue;
}
