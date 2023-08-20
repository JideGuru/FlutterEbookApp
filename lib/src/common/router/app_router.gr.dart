// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    TabsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TabsScreen(),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsScreen(),
      );
    },
    LicensesRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LicensesScreen(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    FavoritesRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FavoritesScreen(),
      );
    },
    GenreRoute.name: (routeData) {
      final args = routeData.argsAs<GenreRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: GenreScreen(
          key: args.key,
          title: args.title,
          url: args.url,
        ),
      );
    },
    ExploreRouteSmall.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ExploreScreenSmall(),
      );
    },
    ExploreRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ExploreScreen(),
      );
    },
    BookDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<BookDetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BookDetailsScreen(
          key: args.key,
          entry: args.entry,
          imgTag: args.imgTag,
          titleTag: args.titleTag,
          authorTag: args.authorTag,
        ),
      );
    },
    DownloadsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DownloadsScreen(),
      );
    },
  };
}

/// generated route for
/// [TabsScreen]
class TabsRoute extends PageRouteInfo<void> {
  const TabsRoute({List<PageRouteInfo>? children})
      : super(
          TabsRoute.name,
          initialChildren: children,
        );

  static const String name = 'TabsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LicensesScreen]
class LicensesRoute extends PageRouteInfo<void> {
  const LicensesRoute({List<PageRouteInfo>? children})
      : super(
          LicensesRoute.name,
          initialChildren: children,
        );

  static const String name = 'LicensesRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FavoritesScreen]
class FavoritesRoute extends PageRouteInfo<void> {
  const FavoritesRoute({List<PageRouteInfo>? children})
      : super(
          FavoritesRoute.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [GenreScreen]
class GenreRoute extends PageRouteInfo<GenreRouteArgs> {
  GenreRoute({
    Key? key,
    required String title,
    required String url,
    List<PageRouteInfo>? children,
  }) : super(
          GenreRoute.name,
          args: GenreRouteArgs(
            key: key,
            title: title,
            url: url,
          ),
          initialChildren: children,
        );

  static const String name = 'GenreRoute';

  static const PageInfo<GenreRouteArgs> page = PageInfo<GenreRouteArgs>(name);
}

class GenreRouteArgs {
  const GenreRouteArgs({
    this.key,
    required this.title,
    required this.url,
  });

  final Key? key;

  final String title;

  final String url;

  @override
  String toString() {
    return 'GenreRouteArgs{key: $key, title: $title, url: $url}';
  }
}

/// generated route for
/// [ExploreScreenSmall]
class ExploreRouteSmall extends PageRouteInfo<void> {
  const ExploreRouteSmall({List<PageRouteInfo>? children})
      : super(
          ExploreRouteSmall.name,
          initialChildren: children,
        );

  static const String name = 'ExploreRouteSmall';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ExploreScreen]
class ExploreRoute extends PageRouteInfo<void> {
  const ExploreRoute({List<PageRouteInfo>? children})
      : super(
          ExploreRoute.name,
          initialChildren: children,
        );

  static const String name = 'ExploreRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [BookDetailsScreen]
class BookDetailsRoute extends PageRouteInfo<BookDetailsRouteArgs> {
  BookDetailsRoute({
    Key? key,
    required Entry entry,
    required String imgTag,
    required String titleTag,
    required String authorTag,
    List<PageRouteInfo>? children,
  }) : super(
          BookDetailsRoute.name,
          args: BookDetailsRouteArgs(
            key: key,
            entry: entry,
            imgTag: imgTag,
            titleTag: titleTag,
            authorTag: authorTag,
          ),
          initialChildren: children,
        );

  static const String name = 'BookDetailsRoute';

  static const PageInfo<BookDetailsRouteArgs> page =
      PageInfo<BookDetailsRouteArgs>(name);
}

class BookDetailsRouteArgs {
  const BookDetailsRouteArgs({
    this.key,
    required this.entry,
    required this.imgTag,
    required this.titleTag,
    required this.authorTag,
  });

  final Key? key;

  final Entry entry;

  final String imgTag;

  final String titleTag;

  final String authorTag;

  @override
  String toString() {
    return 'BookDetailsRouteArgs{key: $key, entry: $entry, imgTag: $imgTag, titleTag: $titleTag, authorTag: $authorTag}';
  }
}

/// generated route for
/// [DownloadsScreen]
class DownloadsRoute extends PageRouteInfo<void> {
  const DownloadsRoute({List<PageRouteInfo>? children})
      : super(
          DownloadsRoute.name,
          initialChildren: children,
        );

  static const String name = 'DownloadsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
