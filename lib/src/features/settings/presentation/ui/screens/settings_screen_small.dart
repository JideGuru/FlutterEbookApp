import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreenSmall extends StatefulWidget {
  const SettingsScreenSmall({super.key});

  @override
  State<SettingsScreenSmall> createState() => _SettingsScreenSmallState();
}

class _SettingsScreenSmallState extends State<SettingsScreenSmall> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    items = [
      {
        'icon': Feather.heart,
        'title': 'Favorites',
        'function': () => _pushPage(const FavoritesRoute()),
      },
      {
        'icon': Feather.download,
        'title': 'Downloads',
        'function': () => _pushPage(const DownloadsRoute()),
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
        'title': 'Open Source Licenses',
        'function': () => _pushPage(const LicensesRoute()),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.isSmallScreen
          ? AppBar(
              centerTitle: true,
              title: const Text('Settings'),
            )
          : null,
      body: Column(
        children: [
          if (!context.isSmallScreen) const SizedBox(height: 30),
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              if (items[index]['title'] == 'Dark Mode') {
                if (context.isPlatformDarkThemed) {
                  return const SizedBox.shrink();
                }
                return _ThemeSwitch(
                  icon: items[index]['icon'] as IconData,
                  title: items[index]['title'] as String,
                );
              }

              return ListTile(
                onTap: items[index]['function'] as Function(),
                leading: Icon(items[index]['icon'] as IconData),
                title: Text(items[index]['title'] as String),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              if (items[index]['title'] == 'Dark Mode' &&
                  context.isPlatformDarkThemed) {
                return const SizedBox.shrink();
              }
              return const Divider();
            },
          ),
        ],
      ),
    );
  }

  void _pushPage(PageRouteInfo route) {
    if (context.isLargeScreen) {
      context.router.replace(route);
    } else {
      context.router.push(route);
    }
  }

  Future<void> showAbout() async {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('About'),
          content: const Text(
            'OpenLeaf is a Simple ebook app by JideGuru using Flutter',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  color: context.theme.colorScheme.secondary,
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
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAppTheme = ref.watch(currentAppThemeNotifierProvider);
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      value: currentAppTheme.value == CurrentAppTheme.dark,
      onChanged: (isDarkMode) {
        ref
            .read(currentAppThemeNotifierProvider.notifier)
            .updateCurrentAppTheme(isDarkMode);
      },
    );
  }
}
