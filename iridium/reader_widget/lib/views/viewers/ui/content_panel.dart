import 'package:flutter/material.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class ContentPanel extends StatefulWidget {
  final ReaderContext readerContext;

  const ContentPanel({Key? key, required this.readerContext}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ContentPanelState();
}

class ContentPanelState extends State<ContentPanel> {
  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: widget.readerContext.tableOfContents.length,
        itemBuilder: itemBuilder,
      );

  Widget itemBuilder(BuildContext context, int index) {
    Link link = widget.readerContext.tableOfContents[index];
    return Material(
      child: ListTile(
        title: Text(link.title ?? ""),
        onTap: () => _onTap(link),
      ),
    );
  }

  void _onTap(Link link) {
    Navigator.pop(context);
    widget.readerContext
        .execute(GoToHrefCommand(link.hrefPart, link.elementId));
  }
}
