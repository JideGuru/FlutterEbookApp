import 'package:mno_navigator/src/epub/decoration.dart';

class DecorationChange {
  static DecorationChangeAdded added(Decoration decoration) =>
      DecorationChangeAdded._(decoration);

  static DecorationChangeUpdated updated(Decoration decoration) =>
      DecorationChangeUpdated._(decoration);

  static DecorationChangeMoved moved(
          String id, int fromPosition, int toPosition) =>
      DecorationChangeMoved._(id, fromPosition, toPosition);

  static DecorationChangeRemoved removed(String id) =>
      DecorationChangeRemoved._(id);
}

class DecorationChangeAdded extends DecorationChange {
  final Decoration decoration;

  DecorationChangeAdded._(this.decoration);
}

class DecorationChangeUpdated extends DecorationChange {
  final Decoration decoration;

  DecorationChangeUpdated._(this.decoration);
}

class DecorationChangeMoved extends DecorationChange {
  final String id;
  final int fromPosition;
  final int toPosition;

  DecorationChangeMoved._(this.id, this.fromPosition, this.toPosition);
}

class DecorationChangeRemoved extends DecorationChange {
  final String id;

  DecorationChangeRemoved._(this.id);
}
