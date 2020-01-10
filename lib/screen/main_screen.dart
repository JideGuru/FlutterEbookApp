import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/providers/app_provider.dart';
import 'package:flutter_ebook_app/screen/home.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            Home(),
            Center(child: Text("1"),),
            Center(child: Text("1"),),
            Center(child: Text("1"),),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          selectedItemColor: Provider.of<AppProvider>(context).theme
              == Constants.lightTheme
              ? Theme.of(context).accentColor
              : Colors.white,
          unselectedItemColor: Colors.grey[500],
          elevation: 20,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Feather.home,
              ),
              title: SizedBox(),
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Feather.book_open,
              ),
              title: SizedBox(),
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Feather.heart,
              ),
              title: SizedBox(),
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Feather.download,
              ),
              title: SizedBox(),
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),

      ),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}
