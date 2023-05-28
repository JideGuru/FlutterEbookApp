import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/features/book_details/screens/book_details_screen.dart';
import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/common/widgets/loading_widget.dart';
import 'package:iridium_reader_widget/util/router.dart';
import 'package:uuid/uuid.dart';


class BookItem extends StatelessWidget {
  final String img;
  final String title;
  final Entry entry;

  BookItem({
    Key? key,
    required this.img,
    required this.title,
    required this.entry,
  }) : super(key: key);

  static const uuid = Uuid();
  final String imgTag = uuid.v4();
  final String titleTag = uuid.v4();
  final String authorTag = uuid.v4();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        MyRouter.pushPage(
          context,
          BookDetailsScreen(
            entry: entry,
            imgTag: imgTag,
            titleTag: titleTag,
            authorTag: authorTag,
          ),
        );
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
    );
  }
}