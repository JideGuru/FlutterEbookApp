import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/widgets/book.dart';

class Downloads extends StatefulWidget {
  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloads"),
//        elevation: 4,
      ),
      body: GridView.builder(
        padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
        shrinkWrap: true,
        itemCount: 12,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 200/400,
        ),
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: BookItem(),
          );
        },
      ),
    );
  }
}
