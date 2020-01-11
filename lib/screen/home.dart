import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/screen/genre.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:flutter_ebook_app/widgets/book_card.dart';
import 'package:flutter_ebook_app/widgets/book_list_item.dart';
import 'package:page_transition/page_transition.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(
          "${Constants.appName}",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: (){},
            icon: Icon(
              Icons.stop,
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
//          SizedBox(height: 20,),

//          Padding(
//            padding: EdgeInsets.symmetric(horizontal: 20),
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: <Widget>[
//                Text(
//                  "Popular Books",
//                  style: TextStyle(
//                    fontSize: 20,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//
//                Text(
//                  "See All",
//                  style: TextStyle(
//                    color: Theme.of(context).accentColor,
//                    fontWeight: FontWeight.w400,
//                  ),
//                ),
//              ],
//            ),
//          ),

//          SizedBox(height: 10,),

          Container(
            height: 200,
            child: Center(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: BookCard(),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 20,),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

//                InkWell(
//                  onTap: (){
//                    Navigator.push(
//                      context,
//                      PageTransition(
//                        type: PageTransitionType.rightToLeft,
//                        child: Category(),
//                      ),
//                    );
//                  },
//                  child: Text(
//                    "See All",
//                    style: TextStyle(
//                      color: Theme.of(context).accentColor,
//                      fontWeight: FontWeight.w400,
//                    ),
//                  ),
//                ),
              ],
            ),
          ),

          SizedBox(height: 10,),

          Container(
            height: 50,
            child: Center(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.all(Radius.circular(20),),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Fiction",
                            style: TextStyle(
                              color: Colors.white,

                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 20,),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Recently Added",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: Genre(),
                      ),
                    );
                  },
                  child: Text(
                    "See All",
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20,),

          ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 12,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: BookListItem(),
              );
            },
          ),
        ],
      ),
    );
  }
}
