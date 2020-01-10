import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/providers/app_provider.dart';
import 'package:flutter_ebook_app/screen/splash.dart';
import 'package:flutter_ebook_app/util/consts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);

    return MaterialApp(
      key: appProvider.key,
      debugShowCheckedModeBanner: false,
      navigatorKey: appProvider.navigatorKey,
      title: Constants.appName,
      theme: appProvider.theme,
//      darkTheme: Constants.darkTheme,
      home: Splash(),
    );
  }
}
