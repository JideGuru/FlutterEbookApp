import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_ebook_app/views/main_screen.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  var timeout = const Duration(seconds: 2);
  var ms = const Duration(milliseconds: 1);

  bool gone = false;

  startTimeout() {
    return new Timer(Duration(seconds: 2), handleTimeout);
  }


  void handleTimeout() {
    changeScreen();
  }

  changeScreen() async {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: MainScreen(),
      ),
    );
    Provider.of<HomeProvider>(context, listen: false).getFeeds();
  }

  @override
  void initState() {
    super.initState();
    startTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Feather.book_open,
              color: Theme.of(context).accentColor,
              size: 70,
            ),
            SizedBox(height: 20,),
            Text(
              "${Constants.appName}",
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
