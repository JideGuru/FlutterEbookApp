import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/podo/category.dart';
import 'package:flutter_ebook_app/providers/genre_provider.dart';
import 'package:flutter_ebook_app/widgets/book_list_item.dart';
import 'package:provider/provider.dart';

class Genre extends StatelessWidget{
  final String title;

  Genre({
    Key key,
    @required this.title,
  }): super(key:key);

  @override
  Widget build(BuildContext context) {
    GenreProvider genreProvider = Provider.of<GenreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("$title"),
      ),
      body: genreProvider.loading
          ? Center(
            child: CircularProgressIndicator(),
          )
          : ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        itemCount: genreProvider.posts.feed.entry.length,
        itemBuilder: (BuildContext context, int index) {
          Entry entry = genreProvider.posts.feed.entry[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: BookListItem(
              img: entry.link[1].href,
              title: entry.title.t,
              author: entry.author.name.t,
              desc: entry.summary.t,
              entry: entry,
            ),
          );
        },
      ),
    );
  }
}
