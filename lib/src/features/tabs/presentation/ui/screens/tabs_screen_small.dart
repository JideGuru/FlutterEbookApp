import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabsScreenSmall extends ConsumerWidget {
  const TabsScreenSmall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        ExploreRoute(),
        SettingsRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: context.theme.primaryColor,
            selectedItemColor: context.theme.colorScheme.secondary,
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
            onTap: tabsRouter.setActiveIndex,
            currentIndex: tabsRouter.activeIndex,
          ),
        );
      },
    );
  }
}
