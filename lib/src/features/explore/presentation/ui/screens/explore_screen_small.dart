import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ExploreScreenSmall extends ConsumerStatefulWidget {
  const ExploreScreenSmall({super.key});

  @override
  ConsumerState<ExploreScreenSmall> createState() => _ExploreScreenSmallState();
}

class _ExploreScreenSmallState extends ConsumerState<ExploreScreenSmall>
    with AutomaticKeepAliveClientMixin {
  void loadData() {
    ref.read(homeFeedNotifierProvider.notifier).fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final homeDataState = ref.watch(homeFeedNotifierProvider);
    return Scaffold(
      appBar: context.isSmallScreen
          ? AppBar(centerTitle: true, title: const Text('Explore'))
          : null,
      body: homeDataState.maybeWhen(
        orElse: () => const SizedBox.shrink(),
        loading: () => const LoadingWidget(),
        data: (feeds) {
          final popular = feeds.popularFeed;
          return ListView.builder(
            itemCount: popular.feed?.link?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              final Link link = popular.feed!.link![index];
              if (!context.isSmallScreen && index == 0) {
                return const SizedBox(height: 30.0);
              }
              // We don't need the tags from 0-9 because
              // they are not categories
              if (index < 10) {
                return const SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: _SectionBookList(link: link),
              );
            },
          );
        },
        error: (_, __) {
          return MyErrorWidget(
            refreshCallBack: () => loadData(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SectionHeader extends StatelessWidget {
  final Link link;
  final bool hideSeeAll;

  const _SectionHeader({required this.link, this.hideSeeAll = false});

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
          if (!hideSeeAll)
            GestureDetector(
              onTap: () {
                context.router.push(
                  GenreRoute(title: '${link.title}', url: link.href!),
                );
              },
              child: Text(
                'See All',
                style: TextStyle(
                  color: context.theme.colorScheme.secondary,
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

class _SectionBookListState extends ConsumerState<_SectionBookList>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _bookCount = ValueNotifier<int>(0);

  void _fetch() {
    ref.read(genreFeedNotifierProvider(widget.link.href!).notifier).fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: _bookCount,
          builder: (context, bookCount, _) {
            return _SectionHeader(
              link: widget.link,
              hideSeeAll: bookCount < 10,
            );
          },
        ),
        const SizedBox(height: 10.0),
        SizedBox(
          height: 200,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: ref
                .watch(genreFeedNotifierProvider(widget.link.href!))
                .maybeWhen(
                  orElse: () => const SizedBox.shrink(),
                  loading: () => const LoadingWidget(),
                  data: (data) {
                    final books = data.books;
                    if (_bookCount.value == 0) {
                      _bookCount.value = books.length;
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final Entry entry = books[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                            vertical: 10.0,
                          ),
                          child:
                              BookCard(img: entry.link![1].href!, entry: entry),
                        );
                      },
                    );
                  },
                  error: (_, __) {
                    return MyErrorWidget(
                      refreshCallBack: () {
                        _fetch();
                      },
                    );
                  },
                ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
