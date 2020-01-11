import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/widgets/book_list_item.dart';

class Genre extends StatefulWidget {
  @override
  _GenreState createState() => _GenreState();
}

class _GenreState extends State<Genre> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fiction"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: BookListItem(),
          );
        },
      ),
    );
  }
}
