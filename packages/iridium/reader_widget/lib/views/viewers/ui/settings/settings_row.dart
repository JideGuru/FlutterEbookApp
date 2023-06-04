import 'package:flutter/material.dart';
import 'package:mno_navigator/epub.dart'
    show
        LetterSpacing,
        LineHeight,
        ReaderThemeBloc,
        ReaderThemeConfig,
        ReaderThemeEvent,
        TextMargin,
        ValueSettings,
        WordSpacing;

class SettingsRow<T extends ValueSettings> extends StatefulWidget {
  final ReaderThemeBloc readerThemeBloc;
  final ReaderThemeConfig readerTheme;
  final String label;
  final T? value;
  final List<T> values;

  const SettingsRow({
    super.key,
    required this.readerThemeBloc,
    required this.readerTheme,
    required this.label,
    required this.value,
    required this.values,
  });

  @override
  State<SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState<T extends ValueSettings> extends State<SettingsRow<T>> {
  ReaderThemeBloc get readerThemeBloc => widget.readerThemeBloc;

  ReaderThemeConfig get readerTheme => widget.readerTheme;

  T? get value => widget.value;

  List<T> get values => widget.values;

  T? findPreviousValue() {
    int index = (value != null) ? values.indexOf(value!) : 0;
    if (index > 0) {
      return values[index - 1];
    }
    return null;
  }

  T? findNextValue() {
    int index = (value != null) ? values.indexOf(value!) : 0;
    if (index < values.length - 1) {
      return values[index + 1];
    }
    return null;
  }

  String get valueLabel => (value != null) ? "${value!.value}" : "auto";

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => applyValue(findPreviousValue()),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: ImageIcon(
                  AssetImage(
                    'packages/iridium_reader_widget/assets/images/icon_minus.png',
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "${widget.label}\n$valueLabel",
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => applyValue(findNextValue()),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: ImageIcon(
                  AssetImage(
                    'packages/iridium_reader_widget/assets/images/icon_plus.png',
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  void applyValue(T? value) {
    if (value != null) {
      readerThemeBloc.add(ReaderThemeEvent(readerTheme.copy(
        textMargin: (value is TextMargin) ? value : null,
        lineHeight: (value is LineHeight) ? value : null,
        wordSpacing: (value is WordSpacing) ? value : null,
        letterSpacing: (value is LetterSpacing) ? value : null,
        advanced: true,
      )));
    }
  }
}
