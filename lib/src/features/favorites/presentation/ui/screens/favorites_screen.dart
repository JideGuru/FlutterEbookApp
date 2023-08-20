import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.isSmallScreen ? null : Colors.transparent,
        centerTitle: true,
        title: const Text('Favorites'),
      ),
      body: ref.watch(favoritesNotifierProvider).maybeWhen(
            orElse: () => const SizedBox.shrink(),
            data: (favorites) {
              if (favorites.isEmpty) const EmptyView();
              return Wrap(
                children: [
                  ...favorites.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 5.0,
                      ),
                      child: BookItem(
                        img: entry.link![1].href!,
                        title: entry.title!.t!,
                        entry: entry,
                      ),
                    );
                  }),
                ],
              );
            },
          ),
    );
  }
}
