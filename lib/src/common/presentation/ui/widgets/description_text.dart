import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';

class DescriptionTextWidget extends StatefulWidget {
  final String text;

  const DescriptionTextWidget({super.key, required this.text});

  @override
  _DescriptionTextWidgetState createState() => _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  late String firstHalf;
  late String secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();
    _splitText();
  }

  void _splitText() {
    if (widget.text.length > 300) {
      firstHalf = widget.text.substring(0, 300);
      secondHalf = widget.text.substring(300, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = '';
    }
  }

  @override
  void didUpdateWidget(covariant DescriptionTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _splitText();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: secondHalf.isEmpty
          ? Text(
              (flag ? firstHalf : (firstHalf + secondHalf))
                  .replaceAll(r'\n', '\n')
                  .replaceAll(r'\r', '')
                  .replaceAll(r"\'", "'"),
              style: TextStyle(
                fontSize: 16.0,
                color: context.theme.textTheme.bodySmall!.color,
              ),
            )
          : Column(
              children: <Widget>[
                Text(
                  (flag ? ('$firstHalf...') : (firstHalf + secondHalf))
                      .replaceAll(r'\n', '\n\n')
                      .replaceAll(r'\r', '')
                      .replaceAll(r"\'", "'"),
                  style: TextStyle(
                    fontSize: 16.0,
                    color: context.theme.textTheme.bodySmall!.color,
                  ),
                ),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        flag ? 'show more' : 'show less',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      flag = !flag;
                    });
                  },
                ),
              ],
            ),
    );
  }
}
