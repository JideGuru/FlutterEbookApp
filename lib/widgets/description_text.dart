import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class DescriptionTextWidget extends StatefulWidget {
  final String text;

  DescriptionTextWidget({@required this.text});

  @override
  _DescriptionTextWidgetState createState() => _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  String firstHalf;
  String secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > 300) {
      firstHalf = widget.text.substring(0, 300);
      secondHalf = widget.text.substring(300, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: secondHalf.isEmpty
          ? Html(
        data: firstHalf,
        onLinkTap: (url) {
          print(url);
        },
        linkStyle: TextStyle(
          color: Colors.blue,
        ),
        defaultTextStyle: TextStyle(
          fontSize: 16,
          color: Theme.of(context).textTheme.caption.color,
        ),
      )
          : Column(
        children: <Widget>[
          Html(
            data: flag ? (firstHalf + "...") : (firstHalf + secondHalf),
            onLinkTap: (url) {
              print(url);
            },
            linkStyle: TextStyle(
              color: Colors.blue,
            ),
            defaultTextStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.caption.color,
            ),
          ),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  flag ? "show more" : "show less",
                  style: TextStyle(color: Colors.blue),
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