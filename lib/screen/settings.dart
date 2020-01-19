import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/providers/app_provider.dart';
import 'package:flutter_ebook_app/providers/favorites_provider.dart';
import 'package:flutter_ebook_app/screen/downloads.dart';
import 'package:flutter_ebook_app/screen/favorites.dart';
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
//    {
//      "icon": Feather.info,
//      "title": "About",
//      "page": Container(),
//    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Settings",
        ),
      ),

      body:  ListView.separated(
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
              if(items[index]['title'] == "About"){

              }else{
                Provider.of<FavoritesProvider>(context, listen: false)
                    .getFeed();
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: items[index]['page'],
                  ),
                );
              }
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
