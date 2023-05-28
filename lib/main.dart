import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/common/constants/strings.dart';
import 'package:flutter_ebook_app/src/features/common/data/local/local_storage.dart';
import 'package:flutter_ebook_app/src/features/common/data/notifiers/current_app_theme/current_app_theme_state_notifier.dart';
import 'package:flutter_ebook_app/src/features/common/database/database_config.dart';
import 'package:flutter_ebook_app/theme/theme_config.dart';
import 'package:flutter_ebook_app/src/features/splash/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sembast/sembast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalStorage();
  await DatabaseConfig.init(StoreRef<dynamic, dynamic>.main());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAppTheme = ref.watch(currentAppThemeStateNotifierProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Strings.appName,
      theme: themeData(
        currentAppTheme == CurrentAppTheme.dark
            ? ThemeConfig.darkTheme
            : ThemeConfig.lightTheme,
      ),
      darkTheme: themeData(ThemeConfig.darkTheme),
      home: const SplashScreen(),
    );
  }

  // Apply font to our app's theme
  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.sourceSansProTextTheme(
        theme.textTheme,
      ),
      colorScheme: theme.colorScheme.copyWith(
        secondary: ThemeConfig.lightAccent,
      ),
    );
  }
}
