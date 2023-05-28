import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/common/constants/strings.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/error_widget.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/loading_widget.dart';
import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/book_card.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/book_list_item.dart';
import 'package:flutter_ebook_app/src/features/explore/screens/genre_screen.dart';
import 'package:flutter_ebook_app/src/features/home/data/notifiers/home_feed_state_notifier.dart';
import 'package:flutter_ebook_app/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void loadData() {
    ref.read(homeDataStateNotifierProvider.notifier).fetch();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeDataStateNotifierProvider).maybeWhen(
            orElse: () => loadData(),
            loadSuccess: (_, __) => null,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeDataState = ref.watch(homeDataStateNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Strings.appName,
          style: const TextStyle(fontSize: 20.0),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: homeDataState.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          loadInProgress: () => const LoadingWidget(),
          loadSuccess: (popular, recent) {
            return RefreshIndicator(
              onRefresh: () async => loadData(),
              child: ListView(
                children: <Widget>[
                  FeaturedSection(popular: popular),
                  const SizedBox(height: 20.0),
                  const _SectionTitle(title: 'Categories'),
                  const SizedBox(height: 10.0),
                  _GenreSection(popular: popular),
                  const SizedBox(height: 20.0),
                  const _SectionTitle(title: 'Recently Added'),
                  const SizedBox(height: 20.0),
                  _NewSection(recent: recent),
                ],
              ),
            );
          },
          loadFailure: () {
            return MyErrorWidget(
              refreshCallBack: () => loadData(),
              isConnection: false,
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedSection extends StatelessWidget {
  final CategoryFeed popular;

  const FeaturedSection({Key? key, required this.popular}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      child: Center(
        child: ListView.builder(
          primary: false,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          scrollDirection: Axis.horizontal,
          itemCount: popular.feed?.entry?.length ?? 0,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            Entry entry = popular.feed!.entry![index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: BookCard(
                img: entry.link![1].href!,
                entry: entry,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GenreSection extends StatelessWidget {
  final CategoryFeed popular;

  const _GenreSection({Key? key, required this.popular}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: Center(
        child: ListView.builder(
          primary: false,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          scrollDirection: Axis.horizontal,
          itemCount: popular.feed?.link?.length ?? 0,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            Link link = popular.feed!.link![index];

            // We don't need the tags from 0-9 because
            // they are not categories
            if (index < 10) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 10.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  onTap: () {
                    MyRouter.pushPage(
                      context,
                      GenreScreen(
                        title: '${link.title}',
                        url: link.href!,
                      ),
                    );
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        '${link.title}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NewSection extends StatelessWidget {
  final CategoryFeed recent;

  const _NewSection({Key? key, required this.recent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.feed?.entry?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        Entry entry = recent.feed!.entry![index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: BookListItem(entry: entry),
        );
      },
    );
  }
}
