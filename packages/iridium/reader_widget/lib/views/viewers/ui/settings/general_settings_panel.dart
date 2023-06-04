import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iridium_reader_widget/views/viewers/model/fonts.dart';
import 'package:iridium_reader_widget/views/viewers/ui/settings/color_theme.dart';
import 'package:iridium_reader_widget/views/viewers/ui/settings/font_size_button.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class GeneralSettingsPanel extends StatefulWidget {
  final ReaderContext readerContext;
  final ViewerSettingsBloc viewerSettingsBloc;
  final ReaderThemeBloc readerThemeBloc;

  const GeneralSettingsPanel({
    super.key,
    required this.readerContext,
    required this.viewerSettingsBloc,
    required this.readerThemeBloc,
  });

  @override
  State<GeneralSettingsPanel> createState() => _GeneralSettingsPanelState();
}

class _GeneralSettingsPanelState extends State<GeneralSettingsPanel> {
  late List<bool> isSelected;

  ReaderContext get readerContext => widget.readerContext;

  ViewerSettingsBloc get viewerSettingsBloc => widget.viewerSettingsBloc;

  ReaderThemeBloc get readerThemeBloc => widget.readerThemeBloc;

  @override
  void initState() {
    super.initState();
    isSelected = [true, false, false];
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFontSizeRow(),
            _buildSelectFontRow(),
            _buildColorThemeRow(),
          ],
        ),
      );

  Widget _buildFontSizeRow() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          FontSizeButton(
            viewerSettingsBloc: viewerSettingsBloc,
            increase: false,
          ),
          const Spacer(),
          FontSizeButton(
            viewerSettingsBloc: viewerSettingsBloc,
            increase: true,
          ),
          const Spacer(),
        ],
      );

  Widget _buildSelectFontRow() => Row(
        children: [
          const Text("Font"),
          const Spacer(),
          BlocBuilder(
              bloc: readerThemeBloc,
              builder: (BuildContext context, ReaderThemeState state) =>
                  DropdownButton<String>(
                      value: state.readerTheme.fontFamily ??
                          Fonts.googleFonts.first,
                      items: Fonts.googleFonts
                          .map((fontFamily) => DropdownMenuItem(
                                value: fontFamily,
                                child: Text(fontFamily),
                                onTap: () {
                                  readerThemeBloc.add(ReaderThemeEvent(
                                      readerThemeBloc.currentTheme.copy(
                                    fontFamily: fontFamily,
                                  )));
                                },
                              ))
                          .toList(),
                      onChanged: (value) {}))
        ],
      );

  Widget _buildColorThemeRow() => ToggleButtons(
        isSelected: isSelected,
        color: Theme.of(context).textTheme.button?.color,
        constraints: const BoxConstraints(
          minWidth: 64.0,
          minHeight: 48.0,
        ),
        onPressed: (index) {
          ColorTheme colorTheme = ColorTheme.values[index];
          readerThemeBloc
              .add(ReaderThemeEvent(readerThemeBloc.currentTheme.copy()
                ..textColor = colorTheme.textColor
                ..backgroundColor = colorTheme.backgroundColor));
          setState(() {
            for (int buttonIndex = 0;
                buttonIndex < isSelected.length;
                buttonIndex++) {
              isSelected[buttonIndex] = buttonIndex == index;
            }
          });
        },
        children: ColorTheme.values
            .map((colorTheme) => Text(colorTheme.name))
            .toList(),
      );
}
