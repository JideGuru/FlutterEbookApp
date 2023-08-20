import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iridium_reader_widget/views/viewers/epub_screen.dart';
import 'package:share_plus/share_plus.dart';

@RoutePage()
class BookDetailsScreen extends ConsumerStatefulWidget {
  final Entry entry;
  final String imgTag;
  final String titleTag;
  final String authorTag;

  const BookDetailsScreen({
    super.key,
    required this.entry,
    required this.imgTag,
    required this.titleTag,
    required this.authorTag,
  });

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.isSmallScreen ? null : Colors.transparent,
        actions: <Widget>[
          ref.watch(favoritesNotifierProvider).maybeWhen(
                orElse: () => const SizedBox.shrink(),
                data: (favorites) {
                  final favorited = favorites.indexWhere(
                        (element) => element.id!.t == widget.entry.id!.t,
                      ) !=
                      -1;
                  return IconButton(
                    onPressed: () async {
                      if (favorited) {
                        ref
                            .watch(favoritesNotifierProvider.notifier)
                            .deleteBook(widget.entry.id!.t ?? '');
                      } else {
                        ref
                            .watch(favoritesNotifierProvider.notifier)
                            .addBook(widget.entry, widget.entry.id!.t ?? '');
                      }
                    },
                    icon: Icon(
                      favorited ? Icons.favorite : Feather.heart,
                      color: favorited
                          ? Colors.red
                          : context.theme.iconTheme.color,
                    ),
                  );
                },
              ),
          IconButton(
            onPressed: () => _share(),
            icon: const Icon(Feather.share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: [
          const SizedBox(height: 10.0),
          _BookDescriptionSection(
            entry: widget.entry,
            authorTag: widget.authorTag,
            imgTag: widget.imgTag,
            titleTag: widget.titleTag,
          ),
          const SizedBox(height: 30.0),
          const _SectionTitle(title: 'Book Description'),
          const _Divider(),
          const SizedBox(height: 10.0),
          DescriptionTextWidget(text: '${widget.entry.summary!.t}'),
          const SizedBox(height: 30.0),
          const _SectionTitle(
            title: 'More from Author',
          ),
          const _Divider(),
          const SizedBox(height: 10.0),
          _MoreBooksFromAuthor(
            authorUrl:
                widget.entry.author!.uri!.t!.replaceAll(r'\&lang=en', ''),
          ),
          const SizedBox(height: 30.0),
        ],
      ),
    );
  }

  void _share() {
    Share.share('${widget.entry.title!.t} by ${widget.entry.author!.name!.t}'
        'Read/Download ${widget.entry.title!.t} from ${widget.entry.link![3].href}.');
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(color: context.theme.textTheme.bodySmall!.color);
  }
}

class _BookDescriptionSection extends StatelessWidget {
  final Entry entry;
  final String imgTag;
  final String titleTag;
  final String authorTag;

  const _BookDescriptionSection({
    required this.entry,
    required this.imgTag,
    required this.titleTag,
    required this.authorTag,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Hero(
          tag: imgTag,
          child: CachedNetworkImage(
            imageUrl: '${entry.link![1].href}',
            placeholder: (context, url) => const SizedBox(
              height: 200.0,
              width: 130.0,
              child: LoadingWidget(),
            ),
            errorWidget: (context, url, error) => const Icon(Feather.x),
            fit: BoxFit.cover,
            height: 200.0,
            width: 130.0,
          ),
        ),
        const SizedBox(width: 20.0),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 5.0),
              Hero(
                tag: titleTag,
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    entry.title!.t!.replaceAll(r'\', ''),
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              Hero(
                tag: authorTag,
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    '${entry.author!.name!.t}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              _CategoryChips(entry: entry),
              Center(
                child: SizedBox(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: _DownloadButton(entry: entry),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final Entry entry;

  const _CategoryChips({required this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry.category == null) {
      return const SizedBox.shrink();
    } else {
      return Wrap(
        children: [
          ...entry.category!.map((category) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    color: context.theme.colorScheme.secondary,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7.0,
                    vertical: 5,
                  ),
                  child: Text(
                    '${category.label}',
                    style: TextStyle(
                      color: context.theme.colorScheme.secondary,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }
  }
}

class _DownloadButton extends ConsumerWidget {
  final Entry entry;

  const _DownloadButton({required this.entry});

  String get id => entry.id!.t.toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = entry.id!.t.toString();
    return ref.watch(downloadsNotifierProvider).maybeWhen(
      orElse: () {
        return _downloadButton(context);
      },
      data: (books) {
        final bookIsDownloaded =
            books.indexWhere((element) => element['id'] == id) != -1;
        if (!bookIsDownloaded) {
          return _downloadButton(context);
        }
        final book = books.firstWhere((element) => element['id'] == id);
        return TextButton(
          onPressed: () => openBook(book['path'] as String, context, ref),
          child: Text(
            'Read Book'.toUpperCase(),
            style: TextStyle(
              fontSize: 15,
              color: context.theme.textTheme.titleLarge?.color ?? Colors.black,
            ),
          ),
        );
      },
    );
  }

  Widget _downloadButton(BuildContext context) => TextButton(
        onPressed: () {
          DownloadAlert.show(
            context: context,
            url: entry.link![3].href!,
            name: entry.title!.t ?? '',
            image: '${entry.link![1].href}',
            id: entry.id!.t.toString(),
          );
        },
        child: Text(
          'Download'.toUpperCase(),
          style: TextStyle(
            fontSize: 15,
            color: context.theme.textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
      );

  Future<void> openBook(
    String path,
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bookFile = File(path);
    if (bookFile.existsSync()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            return EpubScreen.fromPath(filePath: path);
          },
        ),
      );
    } else {
      context.showSnackBarUsingText(
        'Could not find the book file. Please download it again.',
      );
      ref.read(downloadsNotifierProvider.notifier).deleteBook(id);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.theme.colorScheme.secondary,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _MoreBooksFromAuthor extends ConsumerStatefulWidget {
  final String authorUrl;

  const _MoreBooksFromAuthor({
    required this.authorUrl,
  });

  @override
  ConsumerState<_MoreBooksFromAuthor> createState() =>
      _MoreBooksFromAuthorState();
}

class _MoreBooksFromAuthorState extends ConsumerState<_MoreBooksFromAuthor> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookDetailsNotifierProvider(widget.authorUrl).notifier).fetch();
    });
  }

  @override
  void didUpdateWidget(covariant _MoreBooksFromAuthor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authorUrl != widget.authorUrl) {
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(bookDetailsNotifierProvider(widget.authorUrl)).maybeWhen(
          orElse: () => const SizedBox.shrink(),
          loading: () => const LoadingWidget(),
          data: (related) {
            if (related.feed!.entry == null || related.feed!.entry!.isEmpty) {
              return const Text('Empty');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: related.feed!.entry!.length,
              itemBuilder: (BuildContext context, int index) {
                final entry = related.feed!.entry![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: BookListItem(entry: entry),
                );
              },
            );
          },
          error: (_, __) {
            return MyErrorWidget(
              refreshCallBack: () => _fetch(),
            );
          },
        );
  }
}
