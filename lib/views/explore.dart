import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/models/category.dart';
import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_ebook_app/views/genre.dart';
import 'package:flutter_ebook_app/util/api.dart';
import 'package:flutter_ebook_app/components/book_card.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class Explore extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (BuildContext context, HomeProvider homeProvider, Widget child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Explore",
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
                padding: EdgeInsets.symmetric(vertical: 10),
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

                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: Genre(
                                    title: "${link.title}",
                                    url: Api.baseURL+link.href,
                                  ),
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

                    SizedBox(height: 10,),

                    FutureBuilder<CategoryFeed>(
                        future: Api.getCategory(Api.baseURL+link.href),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {

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
                            return Container(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        }
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
