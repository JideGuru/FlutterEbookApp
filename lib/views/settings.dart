import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/view_models/app_provider.dart';
import 'package:flutter_ebook_app/view_models/favorites_provider.dart';
import 'package:flutter_ebook_app/views/downloads.dart';
import 'package:flutter_ebook_app/views/favorites.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List items = [
    {
      "icon": Feather.heart,
      "title": "Favorites",
      "page": Favorites(),
    },
    {
      "icon": Feather.download,
      "title": "Downloads",
      "page": Downloads(),
    },
    {
      "icon": Feather.moon,
      "title": "Dark Mode"
    },
  ];


  @override
  Widget build(BuildContext context) {
    // Remove Dark Switch if Device has Dark mode enaibled
    if( MediaQuery.of(context).platformBrightness == Brightness.dark
        && items.last["title"] == "Dark Mode"){
      items.removeLast();
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Settings",
        ),
      ),

      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          if(items[index]['title'] =="Dark Mode"){
            return SwitchListTile(
              secondary: Icon(
                items[index]['icon'],
              ),
              title: Text(
                items[index]['title'],
              ),
              value: Provider.of<AppProvider>(context).theme == Constants.lightTheme
                  ? false
                  : true,
              onChanged: (v){
                if (v) {
                  Provider.of<AppProvider>(context, listen: false)
                      .setTheme(Constants.darkTheme, "dark");
                } else {
                  Provider.of<AppProvider>(context, listen: false)
                      .setTheme(Constants.lightTheme, "light");
                }
              },
            );
          }

          return ListTile(
            onTap: (){
              Provider.of<FavoritesProvider>(context, listen: false)
                  .getFeed();
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: items[index]['page'],
                ),
              );
            },
            leading: Icon(
              items[index]['icon'],
            ),
            title: Text(
              items[index]['title'],
            ),

          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      ),
    );
  }
}
