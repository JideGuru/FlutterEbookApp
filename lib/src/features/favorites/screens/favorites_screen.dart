import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesStateNotifierProvider.notifier).listen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.isSmallScreen ? null : Colors.transparent,
        centerTitle: true,
        title: const Text('Favorites'),
      ),
      body: ref.watch(favoritesStateNotifierProvider).maybeWhen(
            orElse: () => const SizedBox.shrink(),
            listening: (favorites) {
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
