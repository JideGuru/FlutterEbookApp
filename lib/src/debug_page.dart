import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = context.read(currentAppThemeNotifierProvider).value == CurrentAppTheme.dark;

    return Scaffold(
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Clear Downloads'),
            onTap: () {
              context.read(downloadsNotifierProvider.notifier).clearBooks();
            },
          ),
          ListTile(
            title: const Text('Clear Favorites'),
            onTap: () {
              context.read(favoritesNotifierProvider.notifier).clearBooks();
            },
          ),
          ListTile(
            title: Text('Change Theme to ${isDarkMode ? 'Light' : 'Dark'}'),
            onTap: () {
              ref.read(currentAppThemeNotifierProvider.notifier).updateCurrentAppTheme(
                isDarkMode ? CurrentAppTheme.light : CurrentAppTheme.dark,
              );
            },
          ),
        ],
      ),
    );
  }
}
