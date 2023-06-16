import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/loading_widget.dart';
import 'package:flutter_ebook_app/src/features/common/data/notifiers/downloads/downloads_state_notifier.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/empty_view.dart';
import 'package:flutter_ebook_app/router.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iridium_reader_widget/views/viewers/epub_screen.dart';
import 'package:uuid/uuid.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  static const uuid = Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(downloadsStateNotifierProvider.notifier).listen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Downloads'),
      ),
      body: ref.watch(downloadsStateNotifierProvider).maybeWhen(
        orElse: () {
          return const EmptyView();
        },
        listening: (books) {
          if (books.isEmpty) return const EmptyView();
          return ListView.separated(
            shrinkWrap: true,
            itemCount: books.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> book = books[index];

              return Dismissible(
                key: ObjectKey(uuid.v4()),
                direction: DismissDirection.endToStart,
                background: const _DismissibleBackground(),
                onDismissed: (d) {
                  ref
                      .watch(downloadsStateNotifierProvider.notifier)
                      .deleteBook(book['id']);
                },
                child: InkWell(
                  onTap: () async {
                    String path = book['path'];

                    MyRouter.pushPage(
                      context,
                      EpubScreen.fromPath(filePath: path),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Row(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: book['image'],
                          placeholder: (context, url) => const SizedBox(
                            height: 70.0,
                            width: 70.0,
                            child: LoadingWidget(),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/place.png',
                            fit: BoxFit.cover,
                            height: 70.0,
                            width: 70.0,
                          ),
                          fit: BoxFit.cover,
                          height: 70.0,
                          width: 70.0,
                        ),
                        const SizedBox(width: 10.0),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                book['name'],
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'COMPLETED',
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    book['size'],
                                    style: const TextStyle(
                                      fontSize: 13.0,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          );
        },
      ),
    );
  }
}

class _DismissibleBackground extends StatelessWidget {
  const _DismissibleBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: const Icon(Feather.trash_2, color: Colors.white),
    );
  }
}
