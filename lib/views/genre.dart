import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/models/category.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/components/book_list_item.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Genre extends StatefulWidget{
  final String title;
  final String url;

  Genre({
    Key key,
    @required this.title,
    @required this.url,
  }): super(key:key);

  @override
  _GenreState createState() => _GenreState();
}

class _GenreState extends State<Genre> {

  ScrollController controller = ScrollController();
  List items = List();
  bool loading = true;
  int page = 1;
  bool pagi = false;
  bool showListenerFlag = true;
  bool loadMore = true;

  scrollListener(){
    if(showListenerFlag){
      if (controller.offset >= controller.position.maxScrollExtent &&
          !controller.position.outOfRange) {
        paginate();
      }
    }
  }

  getFeed(){
    setState(() {
      loading = true;
    });
    Api.getCategory(widget.url).then((feed){
      if(mounted){
        setState(() {
          items.addAll(feed.feed.entry);
          loading = false;
        });
      }
    }).catchError((e){
      Fluttertoast.showToast(
        msg: "Something went wrong",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 1,
      );
      throw(e);
    });
  }

  paginate(){
    if(!loading && !pagi && loadMore){
      Timer(Duration(seconds: 1), (){
        controller.jumpTo(controller.position.maxScrollExtent);
      });
      if(mounted){
        setState(() {
          pagi = true;
          page = page+1;
        });
      }
      Fluttertoast.showToast(
        msg: "loading..",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 1,
      );
      print(widget.url+"&page=$page");
      Api.getCategory(widget.url+"&page=$page").then((feed){
        if(mounted){
          setState(() {
            items.addAll(feed.feed.entry);
            pagi = false;
          });
        }
        Fluttertoast.showToast(
          msg: "loaded!",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIos: 1,
        );
      }).catchError((e){
        Fluttertoast.showToast(
          msg: "Something went wrong",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIos: 1,
        );
        setState(() {
          loadMore = false;
          pagi = false;
        });
        throw(e);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getFeed();
    controller.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("${widget.title}"),
      ),
      body: loading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        controller: controller,
        children: <Widget>[
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 10),
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              Entry entry = items[index];
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

          SizedBox(height: 10,),

          pagi
              ?Container(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              :SizedBox(),
        ],
      ),
    );
  }
}
