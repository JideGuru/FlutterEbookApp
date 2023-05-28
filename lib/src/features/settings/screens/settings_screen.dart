import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/common/data/notifiers/current_app_theme/current_app_theme_state_notifier.dart';
import 'package:flutter_ebook_app/src/features/downloads/screens/download_screen.dart';
import 'package:flutter_ebook_app/router.dart';
import 'package:flutter_ebook_app/src/features/favorites/screens/favorites_screen.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    items = [
      {
        'icon': Feather.heart,
        'title': 'Favorites',
        'function': () => _pushPage(const FavoritesScreen()),
      },
      {
        'icon': Feather.download,
        'title': 'Downloads',
        'function': () => _pushPage(const DownloadsScreen()),
      },
      {
        'icon': Feather.moon,
        'title': 'Dark Mode',
        'function': null,
      },
      {
        'icon': Feather.info,
        'title': 'About',
        'function': () => showAbout(),
      },
      {
        'icon': Feather.file_text,
        'title': 'Licenses',
        'function': () => _pushPageDialog(const LicensePage()),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Remove Dark Switch if Device has Dark mode enabled
    if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
      items.removeWhere((item) => item['title'] == 'Dark Mode');
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Settings',
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          if (items[index]['title'] == 'Dark Mode') {
            return _ThemeSwitch(
              icon: items[index]['icon'],
              title: items[index]['title'],
            );
          }

          return ListTile(
            onTap: items[index]['function'],
            leading: Icon(items[index]['icon']),
            title: Text(items[index]['title']),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),
    );
  }

  void _pushPage(Widget page) {
    MyRouter.pushPage(context, page);
  }

  void _pushPageDialog(Widget page) {
    MyRouter.pushPageDialog(context, page);
  }

  Future<void> showAbout() async {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'About',
          ),
          content: const Text(
            'Simple eBook app by JideGuru',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeSwitch extends ConsumerWidget {
  final IconData icon;
  final String title;

  const _ThemeSwitch({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAppTheme = ref.watch(currentAppThemeStateNotifierProvider);
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      value: currentAppTheme == CurrentAppTheme.dark,
      onChanged: (isDarkMode) {
        ref
            .read(currentAppThemeStateNotifierProvider.notifier)
            .updateCurrentAppTheme(isDarkMode);
      },
    );
  }
}
