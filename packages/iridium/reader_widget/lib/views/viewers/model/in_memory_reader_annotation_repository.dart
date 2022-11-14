import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class InMemoryReaderAnnotationRepository extends ReaderAnnotationRepository {
  int _currentId = 0;
  final List<ReaderAnnotation> annotations = [];

  @override
  Future<List<ReaderAnnotation>> allWhere(
          {Predicate<ReaderAnnotation> predicate =
              const AcceptAllPredicate()}) async =>
      annotations.where(predicate.test).toList();

  @override
  Future<ReaderAnnotation> createReaderAnnotation(
      PaginationInfo paginationInfo) async {
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
        "$_currentId", paginationInfo.location.json, AnnotationType.bookmark);
    _currentId++;
    annotations.add(readerAnnotation);
    return readerAnnotation;
  }

  @override
  Future<void> delete(List<String> deletedIds) async =>
      annotations.removeWhere((element) => deletedIds.contains(element.id));
}
