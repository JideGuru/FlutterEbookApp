import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logman/logman.dart';

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();
  
  void sayHello(){
  print('Hello World');
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAppTheme = ref.watch(currentAppThemeNotifierProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: themeData(
        currentAppTheme.value == CurrentAppTheme.dark ? darkTheme : lightTheme,
      ),
      darkTheme: themeData(darkTheme),
      themeMode: currentAppTheme.value?.themeMode,
      routerConfig: _appRouter.config(
        navigatorObservers: () => [
          LogmanNavigatorObserver(),
        ],
      ),
    );
  }

  // Apply font to our app's theme
  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.sourceSansProTextTheme(
        theme.textTheme,
      ),
      colorScheme: theme.colorScheme.copyWith(
        secondary: lightAccent,
      ),
    );
  }
}
