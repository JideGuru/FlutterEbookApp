import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart';

class FontSizeButton extends StatelessWidget {
  final ViewerSettingsBloc viewerSettingsBloc;
  final bool increase;

  const FontSizeButton({
    super.key,
    required this.viewerSettingsBloc,
    required this.increase,
  });

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.transparency,
        child: IconButton(
          splashRadius: 24.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          onPressed: () => viewerSettingsBloc
              .add((increase) ? IncrFontSizeEvent() : DecrFontSizeEvent()),
          icon: ImageIcon(
            AssetImage(
              (increase)
                  ? 'packages/iridium_reader_widget/assets/images/icon_font_increase.png'
                  : 'packages/iridium_reader_widget/assets/images/icon_font_decrease.png',
            ),
          ),
        ),
      );
}
