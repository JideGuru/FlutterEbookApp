import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/modal_dialogs/exit_modal_dialog.dart';
import 'package:flutter_ebook_app/src/features/explore/screens/explore_screen.dart';
import 'package:flutter_ebook_app/src/features/home/data/notifiers/home_feed_state_notifier.dart';
import 'package:flutter_ebook_app/src/features/home/screens/home_screen.dart';
import 'package:flutter_ebook_app/src/features/settings/screens/settings_screen.dart';
import 'package:flutter_ebook_app/src/features/tabs/data/notifiers/current_tab_notifier.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabsScreen extends ConsumerWidget {
  const TabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabNotifierProvider);

    // watch providers so they dnt get disposed
    ref.watch(homeDataStateNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        return await ExitModalDialog.show(context: context) ?? false;
      },
      child: ValueListenableBuilder<int>(
        valueListenable: currentTab,
        builder: (context, page, _) {
          return Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: () {
                switch (page) {
                  case 0:
                    return const HomeScreen();
                  case 1:
                    return const ExploreScreen();
                  case 2:
                    return const SettingsScreen();
                  default:
                    return const HomeScreen();
                }
              }(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Theme.of(context).primaryColor,
              selectedItemColor: Theme.of(context).colorScheme.secondary,
              unselectedItemColor: Colors.grey[500],
              elevation: 20,
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Feather.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Feather.compass),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Feather.settings),
                  label: 'Settings',
                ),
              ],
              onTap: currentTab.changePage,
              currentIndex: page,
            ),
          );
        },
      ),
    );
  }
}
