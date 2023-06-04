import 'package:flutter/material.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class AnnotationsPanel extends StatefulWidget {
  final ReaderContext readerContext;
  final AnnotationType annotationType;

  const AnnotationsPanel({
    super.key,
    required this.readerContext,
    required this.annotationType,
  });

  @override
  State<StatefulWidget> createState() => AnnotationsPanelState();
}

class AnnotationsPanelState extends State<AnnotationsPanel> {
  Future<List<ReaderAnnotation>> get _readerAnnotationsStream =>
      widget.readerContext.readerAnnotationRepository
          .allWhere(predicate: AnnotationTypePredicate(widget.annotationType));

  @override
  Widget build(BuildContext context) => FutureBuilder<List<ReaderAnnotation>>(
        initialData: const [],
        future: _readerAnnotationsStream,
        builder: (context, snapshot) => ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) =>
              itemBuilder(context, snapshot.data![index]),
        ),
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
