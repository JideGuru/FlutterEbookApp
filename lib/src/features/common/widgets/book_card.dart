import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/features.dart';
import 'package:flutter_ebook_app/src/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class BookCard extends ConsumerWidget {
  final String img;
  final Entry entry;

  BookCard({
    Key? key,
    required this.img,
    required this.entry,
  }) : super(key: key);

  static const uuid = Uuid();
  final String imgTag = uuid.v4();
  final String titleTag = uuid.v4();
  final String authorTag = uuid.v4();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 120.0,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        elevation: 4.0,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          onTap: () {
            bool isHomeTab = ref.read(currentTabNotifierProvider).isHomeTab;
            final route = BookDetailsRoute(
              entry: entry,
              imgTag: imgTag,
              titleTag: titleTag,
              authorTag: authorTag,
            );
            if (context.isSmallScreen || !isHomeTab) {
              context.router.push(route);
            } else {
              context.router.replace(route);
            }
          },
          child: ClipRRect(
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
