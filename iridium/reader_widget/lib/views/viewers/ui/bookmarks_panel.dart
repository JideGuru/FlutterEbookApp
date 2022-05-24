import 'package:flutter/material.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_navigator/src/publication/model/annotation_type_predicate.dart';
import 'package:mno_shared/publication.dart';

class BookmarksPanel extends StatefulWidget {
  final ReaderContext readerContext;

  const BookmarksPanel({Key? key, required this.readerContext})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => BookmarksPanelState();
}

class BookmarksPanelState extends State<BookmarksPanel> {
  Future<List<ReaderAnnotation>> get _readerAnnotationsStream => widget
      .readerContext.readerAnnotationRepository
      .allWhere(predicate: AnnotationTypePredicate(AnnotationType.bookmark));

  @override
  Widget build(BuildContext context) => FutureBuilder<List<ReaderAnnotation>>(
        initialData: const [],
        future: _readerAnnotationsStream,
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) =>
                itemBuilder(context, snapshot.data![index]),
          );
        },
      );

  Widget itemBuilder(BuildContext context, ReaderAnnotation readerAnnotation) {
    Locator? locator = Locator.fromJsonString(readerAnnotation.location);
    String? title =
        (locator?.title?.isNotEmpty == true) ? locator?.title : null;
    String? text = locator?.text.highlight;
    return Material(
      child: ListTile(
        title: Text(title ?? text ?? ""),
        onTap: () => _onTap(readerAnnotation),
      ),
    );
  }

  void _onTap(ReaderAnnotation readerAnnotation) {
    Navigator.pop(context);
    widget.readerContext
        .execute(GoToLocationCommand(readerAnnotation.location));
  }
}
