import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iridium_reader_widget/views/viewers/ui/settings/settings_row.dart';
import 'package:iridium_reader_widget/views/viewers/ui/settings/alignment_button.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class AdvancedSettingsPanel extends StatefulWidget {
  final ReaderContext readerContext;
  final ReaderThemeBloc readerThemeBloc;

  const AdvancedSettingsPanel({
    super.key,
    required this.readerContext,
    required this.readerThemeBloc,
  });

  @override
  State<AdvancedSettingsPanel> createState() => _AdvancedSettingsPanelState();
}

class _AdvancedSettingsPanelState extends State<AdvancedSettingsPanel> {
  ReaderThemeBloc get readerThemeBloc => widget.readerThemeBloc;

  @override
  Widget build(BuildContext context) => BlocBuilder(
      bloc: readerThemeBloc,
      builder: (BuildContext context, ReaderThemeState state) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPublishersDefaultRow(state),
                _buildTextAlignmentRow(state),
                _buildPageMarginRow(state),
                _buildWordSpacingRow(state),
                _buildLetterSpacingRow(state),
                _buildLineSpacingRow(state),
              ],
            ),
          ));

  Widget _buildPublishersDefaultRow(ReaderThemeState state) => SwitchListTile(
        title: const Text("Publisher's default"),
        value: !state.readerTheme.advanced,
        onChanged: (value) =>
            readerThemeBloc.add(ReaderThemeEvent(state.readerTheme.copy(
          advanced: !value,
        ))),
      );

  Widget _buildTextAlignmentRow(ReaderThemeState state) => Row(
        children: [TextAlign.left, TextAlign.justify]
            .map((textAlign) => Expanded(
                  child: AlignmentButton(
                    readerThemeBloc: widget.readerThemeBloc,
                    readerTheme: state.readerTheme,
                    textAlign: textAlign,
                  ),
                ))
            .toList(),
      );

  Widget _buildPageMarginRow(ReaderThemeState state) => SettingsRow<TextMargin>(
        readerThemeBloc: widget.readerThemeBloc,
        readerTheme: state.readerTheme,
        label: "Page Margins",
        value: state.readerTheme.textMargin,
        values: TextMargin.values,
      );

  Widget _buildWordSpacingRow(ReaderThemeState state) =>
      SettingsRow<WordSpacing>(
        readerThemeBloc: widget.readerThemeBloc,
        readerTheme: state.readerTheme,
        label: "Word Spacing",
        value: state.readerTheme.wordSpacing,
        values: WordSpacing.values,
      );

  Widget _buildLetterSpacingRow(ReaderThemeState state) =>
      SettingsRow<LetterSpacing>(
        readerThemeBloc: widget.readerThemeBloc,
        readerTheme: state.readerTheme,
        label: "Letter Spacing",
        value: state.readerTheme.letterSpacing,
        values: LetterSpacing.values,
      );

  Widget _buildLineSpacingRow(ReaderThemeState state) =>
      SettingsRow<LineHeight>(
        readerThemeBloc: widget.readerThemeBloc,
        readerTheme: state.readerTheme,
        label: "Line Height",
        value: state.readerTheme.lineHeight,
        values: LineHeight.values,
      );
}
