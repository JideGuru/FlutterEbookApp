import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class BookItem extends ConsumerWidget {
  final String img;
  final String title;
  final Entry entry;

  BookItem({
    super.key,
    required this.img,
    required this.title,
    required this.entry,
  });

  static const uuid = Uuid();
  final String imgTag = uuid.v4();
  final String titleTag = uuid.v4();
  final String authorTag = uuid.v4();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 150,
      child: InkWell(
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
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(10.0),
              ),
              child: Hero(
                tag: imgTag,
                child: CachedNetworkImage(
                  imageUrl: img,
                  placeholder: (context, url) => const LoadingWidget(
                    isImage: true,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/place.png',
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                  height: 150.0,
                ),
              ),
            ),
            const SizedBox(height: 5.0),
            Hero(
              tag: titleTag,
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  title.replaceAll(r'\', ''),
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
