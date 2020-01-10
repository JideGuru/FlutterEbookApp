import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/providers/app_provider.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List items = [
    {
      "icon": Feather.heart,
      "title": "Favorites"
    },
    {
      "icon": Feather.download,
      "title": "Downloads"
    },
    {
      "icon": Feather.moon,
      "title": "Dark Mode"
    },
    {
      "icon": Feather.info,
      "title": "About"
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
        ),
      ),

      body: ListView(
        children: <Widget>[

          Container(
            height: 200,
            color: Theme.of(context).accentColor,
            child: Center(
              child: Text(
                "Phone Name",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: 20,),

          ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return items[index]['title'] =="Dark Mode"
                  ? SwitchListTile(
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
              )
                  : ListTile(
                onTap: (){},
                leading: Icon(
                  items[index]['icon'],
                ),
                title: Text(
                  items[index]['title'],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
