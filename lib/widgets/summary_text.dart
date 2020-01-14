import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class SummaryTextWidget extends StatefulWidget {
  final String text;

  SummaryTextWidget({@required this.text});

  @override
  _SummaryTextWidgetState createState() => _SummaryTextWidgetState();
}

class _SummaryTextWidgetState extends State<SummaryTextWidget> {
  String firstHalf;
  String secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > 100) {
      firstHalf = widget.text.substring(0, 100);
      secondHalf = widget.text.substring(100, widget.text.length);
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
          fontSize: 14,
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
              fontSize: 14,
              color: Theme.of(context).textTheme.caption.color,
            ),
          ),
//          InkWell(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: <Widget>[
//                Text(
//                  flag ? "show more" : "show less",
//                  style: TextStyle(color: Colors.blue),
//                ),
//              ],
//            ),
//            onTap: () {
//              setState(() {
//                flag = !flag;
//              });
//            },
//          ),
        ],
      ),
    );
  }
}