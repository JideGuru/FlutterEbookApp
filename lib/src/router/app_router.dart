import 'package:auto_route/auto_route.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes {
    return <AutoRoute>[
      AutoRoute(
        page: SplashRoute.page,
        path: '/',
      ),
      CupertinoRoute(
        page: TabsRoute.page,
        path: '/tabs-screen',
        children: <AutoRoute>[
          CupertinoRoute(
            page: HomeRoute.page,
            path: 'home-tab',
          ),
          CupertinoRoute(
            page: ExploreRoute.page,
            path: 'explore-tab',
          ),
          CupertinoRoute(
            page: SettingsRoute.page,
            path: 'settings-tab',
          ),
        ],
      ),
      CupertinoRoute(
        page: BookDetailsRoute.page,
        path: '/book-details-tab',
      ),
      CupertinoRoute(
        page: ExploreRoute.page,
        path: '/explore-tab',
      ),
      CupertinoRoute(
        page: GenreRoute.page,
        path: '/genre-tab',
      ),
      CupertinoRoute(
        page: DownloadsRoute.page,
        path: '/downloads-tab',
      ),
      CupertinoRoute(
        page: FavoritesRoute.page,
        path: '/favorites-tab',
      ),
    ];
  }
}
