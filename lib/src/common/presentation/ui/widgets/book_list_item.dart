import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class BookListItem extends ConsumerWidget {
  final Entry entry;

  BookListItem({
    super.key,
    required this.entry,
  });

  static const uuid = Uuid();
  final String imgTag = uuid.v4();
  final String titleTag = uuid.v4();
  final String authorTag = uuid.v4();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        final bool isHomeTab = ref.read(currentTabNotifierProvider).isHomeTab;
        final route = BookDetailsRoute(
          entry: entry,
          imgTag: imgTag,
          titleTag: titleTag,
          authorTag: authorTag,
        );

        if (context.isLargeScreen && isHomeTab) {
          context.router.replace(route);
        } else {
          context.router.push(route);
        }
      },
      child: SizedBox(
        height: 150.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              elevation: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                child: Hero(
                  tag: imgTag,
                  child: CachedNetworkImage(
                    imageUrl: entry.link![1].href!,
                    placeholder: (context, url) => const SizedBox(
                      height: 150.0,
                      width: 100.0,
                      child: LoadingWidget(
                        isImage: true,
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/place.png',
                      fit: BoxFit.cover,
                      height: 150.0,
                      width: 100.0,
                    ),
                    fit: BoxFit.cover,
                    height: 150.0,
                    width: 100.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: titleTag,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        entry.title!.t!.replaceAll(r'\', ''),
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: context.theme.textTheme.titleLarge!.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Hero(
                    tag: authorTag,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        entry.author!.name!.t!,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          color: context.theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    '${entry.summary!.t!.length < 100 ? entry.summary!.t! : entry.summary!.t!.substring(0, 100)}...'
                        .replaceAll(r'\n', '\n')
                        .replaceAll(r'\r', '')
                        .replaceAll(r'\"', '"'),
                    style: TextStyle(
                      fontSize: 13.0,
                      color: context.theme.textTheme.bodySmall!.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
