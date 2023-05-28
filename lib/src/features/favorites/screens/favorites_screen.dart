import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/common/data/notifiers/favorites/favorites_state_notifier.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/book_item.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/empty_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        centerTitle: true,
        title: const Text('Favorites'),
      ),
      body: ref.watch(favoritesStateNotifierProvider).maybeWhen(
            orElse: () => const SizedBox.shrink(),
            listening: (favorites) {
              if (favorites.isEmpty) const EmptyView();
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                shrinkWrap: true,
                itemCount: favorites.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 200 / 340,
                ),
                itemBuilder: (BuildContext context, int index) {
                  Entry entry = favorites[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: BookItem(
                      img: entry.link![1].href!,
                      title: entry.title!.t!,
                      entry: entry,
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
