import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:flutter_ebook_app/view_models/app_provider.dart';
import 'package:flutter_ebook_app/view_models/favorites_provider.dart';
import 'package:flutter_ebook_app/views/downloads.dart';
import 'package:flutter_ebook_app/views/favorites.dart';
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
      "title": "Dark Mode",
    },
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
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          if (items[index]['title'] == "Dark Mode") {
            return _buildThemeSwitch(items[index]);
          }

          return ListTile(
            onTap: () {
              Provider.of<FavoritesProvider>(context, listen: false).getFeed();
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

  Widget _buildThemeSwitch(Map item) {
    // Do not display a Dark Mode switch if platform is iOS
    // or Android 10 (because of the native Dark Mode theme)
    if (Platform.isAndroid) {
      return SwitchListTile(
        secondary: Icon(
          item['icon'],
        ),
        title: Text(
          item['title'],
        ),
        value: Provider.of<AppProvider>(context).theme == Constants.lightTheme
            ? false
            : true,
        onChanged: (v) {
          if (v) {
            Provider.of<AppProvider>(context, listen: false)
                .setTheme(Constants.darkTheme, "dark");
          } else {
            Provider.of<AppProvider>(context, listen: false)
                .setTheme(Constants.lightTheme, "light");
          }
        },
      );
    } else {
      return SizedBox();
    }
  }
}
