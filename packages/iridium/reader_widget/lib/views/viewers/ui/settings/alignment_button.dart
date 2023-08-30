import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';

class AlignmentButton extends StatelessWidget {
  final ReaderThemeBloc readerThemeBloc;
  final ReaderThemeConfig readerTheme;
  final TextAlign textAlign;

  const AlignmentButton({
    super.key,
    required this.readerThemeBloc,
    required this.readerTheme,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(),
          color: readerTheme.textAlign == textAlign
              ? Theme.of(context).backgroundColor
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              readerThemeBloc.add(ReaderThemeEvent(readerTheme.copy(
                textAlign: textAlign,
                advanced: true,
              )));
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ImageIcon(
                AssetImage(
                  'packages/iridium_reader_widget/assets/images/icon_${textAlign.name}.png',
                ),
              ),
            ),
          ),
        ),
      );
}
