import 'package:mno_navigator/src/epub/decoration.dart';

class DecorationStyleAnnotationMark extends DecorationStyle with Tinted {
  @override
  final int tint;

  DecorationStyleAnnotationMark({required this.tint});

  @override
  String toString() => '$runtimeType{tint: $tint}';
}
