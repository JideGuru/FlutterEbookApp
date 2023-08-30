import 'package:dartx/dartx.dart';
import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class InMemoryReaderAnnotationRepository extends ReaderAnnotationRepository {
  static const String _bookId = "book";
  int _currentId = 0;
  final List<ReaderAnnotation> annotations = [];
  ReaderAnnotation? position;

  @override
  Future<List<ReaderAnnotation>> allWhere(
          {Predicate<ReaderAnnotation> predicate =
              const AcceptAllPredicate()}) async =>
      annotations.where(predicate.test).toList();

  @override
  Future<ReaderAnnotation> savePosition(PaginationInfo paginationInfo) async {
    ReaderAnnotation readerAnnotation = ReaderAnnotation("$_currentId", _bookId,
        paginationInfo.locator.json, AnnotationType.bookmark);
    _currentId++;
    annotations.add(readerAnnotation);
    position = readerAnnotation;
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation?> getPosition() async => position;

  @override
  Future<ReaderAnnotation> createBookmark(PaginationInfo paginationInfo) async {
    ReaderAnnotation readerAnnotation = ReaderAnnotation("$_currentId", _bookId,
        paginationInfo.locator.json, AnnotationType.bookmark);
    _currentId++;
    annotations.add(readerAnnotation);
    notifyBookmark(readerAnnotation);
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation> createHighlight(
      PaginationInfo? paginationInfo,
      Locator locator,
      HighlightStyle? style,
      int? tint,
      String? annotation) async {
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
      "$_currentId",
      _bookId,
      locator.json,
      AnnotationType.highlight,
      style: style,
      tint: tint,
      annotation: annotation,
    );
    _currentId++;
    annotations.add(readerAnnotation);
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation?> get(String id) async =>
      annotations.firstOrNullWhere((element) => element.id == id);

  @override
  void save(ReaderAnnotation readerAnnotation) {}

  @override
  Future<void> delete(Iterable<String> deletedIds) async {
    annotations.removeWhere((element) => deletedIds.contains(element.id));
    super.delete(deletedIds);
  }
}
