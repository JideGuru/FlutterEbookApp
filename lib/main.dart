import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/view_models/app_provider.dart';
import 'package:flutter_ebook_app/view_models/details_provider.dart';
import 'package:flutter_ebook_app/view_models/favorites_provider.dart';
import 'package:flutter_ebook_app/view_models/home_provider.dart';
import 'package:flutter_ebook_app/views/splash.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
     providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DetailsProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget child) {
        return MaterialApp(
          key: appProvider.key,
          debugShowCheckedModeBanner: false,
          navigatorKey: appProvider.navigatorKey,
          title: Constants.appName,
          theme: appProvider.theme,
          darkTheme: Constants.darkTheme,
          home: Splash(),
        );
      },
    );
  }
}
