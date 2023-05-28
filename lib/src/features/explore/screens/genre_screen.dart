import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/loading_widget.dart';
import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/book_list_item.dart';
import 'package:flutter_ebook_app/src/features/explore/notifiers/genre_feed/genre_feed_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenreScreen extends ConsumerStatefulWidget {
  final String title;
  final String url;

  const GenreScreen({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  ConsumerState<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends ConsumerState<GenreScreen> {
  final _scrollController = ScrollController();
  int page = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(genreFeedStateNotifierProvider(widget.url).notifier).fetch();
    });
    _scrollController.addListener(paginationListener);
  }

  void paginationListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.watch(genreFeedStateNotifierProvider(widget.url)).maybeWhen(
        loadSuccess: (_, loadingMore) {
          if (!loadingMore) {
            page += 1;
            ref
                .read(genreFeedStateNotifierProvider(widget.url).notifier)
                .paginate(page);
            // Animate to bottom of list
            Timer(const Duration(milliseconds: 100), () {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeIn,
              );
            });
          }
        },
        orElse: () {
          return;
        },
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(paginationListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: ref.watch(genreFeedStateNotifierProvider(widget.url)).maybeWhen(
              orElse: () => const SizedBox.shrink(),
              loadInProgress: () => const LoadingWidget(),
              loadSuccess: (books, loadingMore) {
                return ListView(
                  controller: _scrollController,
                  children: <Widget>[
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      shrinkWrap: true,
                      itemCount: books.length,
                      itemBuilder: (BuildContext context, int index) {
                        Entry entry = books[index];
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: BookListItem(entry: entry),
                        );
                      },
                    ),
                    const SizedBox(height: 10.0),
                    if (loadingMore)
                      const SizedBox(height: 80.0, child: LoadingWidget()),
                  ],
                );
              },
            ),
      ),
    );
  }
}
