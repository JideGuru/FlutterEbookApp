import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/error_widget.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/loading_widget.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/book_card.dart';
import 'package:flutter_ebook_app/src/features/explore/notifiers/genre_feed/genre_feed_state_notifier.dart';
import 'package:flutter_ebook_app/src/features/explore/screens/genre_screen.dart';
import 'package:flutter_ebook_app/src/features/home/data/notifiers/home_feed_state_notifier.dart';
import 'package:flutter_ebook_app/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  void loadData() {
    ref.read(homeDataStateNotifierProvider.notifier).fetch();
  }

  @override
  Widget build(BuildContext context) {
    final homeDataState = ref.watch(homeDataStateNotifierProvider);
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Explore')),
      body: homeDataState.maybeWhen(
        orElse: () => const SizedBox.shrink(),
        loadInProgress: () => const LoadingWidget(),
        loadSuccess: (popular, recent) {
          return ListView.builder(
            itemCount: popular.feed?.link?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              Link link = popular.feed!.link![index];

              // We don't need the tags from 0-9 because
              // they are not categories
              if (index < 10) {
                return const SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: <Widget>[
                    _SectionHeader(link: link),
                    const SizedBox(height: 10.0),
                    _SectionBookList(link: link),
                  ],
                ),
              );
            },
          );
        },
        loadFailure: () {
          return MyErrorWidget(
            refreshCallBack: () => loadData(),
            isConnection: false,
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final Link link;

  const _SectionHeader({required this.link});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              '${link.title}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              MyRouter.pushPage(
                context,
                GenreScreen(
                  title: '${link.title}',
                  url: link.href!,
                ),
              );
            },
            child: Text(
              'See All',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBookList extends ConsumerStatefulWidget {
  final Link link;

  const _SectionBookList({required this.link});

  @override
  ConsumerState<_SectionBookList> createState() => _SectionBookListState();
}

class _SectionBookListState extends ConsumerState<_SectionBookList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(genreFeedStateNotifierProvider(widget.link.href!).notifier)
          .fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: ref
            .watch(genreFeedStateNotifierProvider(widget.link.href!))
            .maybeWhen(
              orElse: () => const SizedBox.shrink(),
              loadInProgress: () => const LoadingWidget(),
              loadSuccess: (books, __) {
                return Center(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      Entry entry = books[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 10.0,
                        ),
                        child:
                            BookCard(img: entry.link![1].href!, entry: entry),
                      );
                    },
                  ),
                );
              },
              loadFailure: () {
                return MyErrorWidget(
                  refreshCallBack: () {
                    ref
                        .read(genreFeedStateNotifierProvider(widget.link.href!)
                            .notifier)
                        .fetch();
                  },
                  isConnection: false,
                );
              },
            ),
      ),
    );
  }
}
