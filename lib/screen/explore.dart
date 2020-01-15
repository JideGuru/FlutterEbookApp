import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/podo/category.dart';
import 'package:flutter_ebook_app/providers/home_provider.dart';
import 'package:flutter_ebook_app/screen/favorites.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/widgets/book_card.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  @override
  Widget build(BuildContext context) {
    HomeProvider homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: MediaQuery.of(context).size.width,
          height: 45,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: TextField(
                onSubmitted: (value){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Favorites()),
                  );
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search",
                  suffixIcon: Icon(
                    Feather.search,
                    color: Theme.of(context).iconTheme.color,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      body: homeProvider.loading
          ? Center(child: CircularProgressIndicator(),)
          : ListView.builder(
        itemCount: homeProvider.top.feed.link.length,
        itemBuilder: (BuildContext context, int index) {
          Link link = homeProvider.top.feed.link[index];

          if(index < 10){
            return SizedBox();
          }

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "${link.title}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "See All",
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10,),

                FutureBuilder<CategoryFeed>(
                  future: Api.getCategory(link.href),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {

                      print(snapshot.data.toString());
                      CategoryFeed category = snapshot.data;

                      return Container(
                        height: 200,
                        child: Center(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            scrollDirection: Axis.horizontal,
                            itemCount: category.feed.entry.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              Entry entry = category.feed.entry[index];

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                child: BookCard(
                                  img: entry.link[1].href,
                                  entry: entry,
                                ),
                              );
                            },
                          ),
                        ),
                      );

                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }
                ),
              ],
            ),
          );
        },

      ),

    );
  }
}
