// Copyright (c) 2022 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:mno_navigator/cbz.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_server/mno_server.dart';
import 'package:mno_shared/publication.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CbzNavigator extends PublicationNavigator {
  final CbzController cbzController;

  CbzNavigator({
    super.key,
    required super.waitingScreenBuilder,
    required super.displayErrorBuilder,
    required super.onReaderContextCreated,
    required super.wrapper,
    required this.cbzController,
  }) : super(
          publicationController: cbzController,
        );

  @override
  State<StatefulWidget> createState() => CbzNavigatorState();
}

class CbzNavigatorState extends PublicationNavigatorState<CbzNavigator> {
  static const double minScaleFactor = 0.999;
  static const double maxScaleFactor = 3.0;

  CbzController get cbzController => widget.cbzController;

  @override
  Widget buildReaderView(List<Link> spine, ServerStarted serverState) =>
      TapGesture(
        onTap: onTap,
        child: PhotoViewGallery.builder(
          pageController: cbzController.pageController,
          builder: (BuildContext context, int index) =>
              _buildItem(spine[index], serverState),
          itemCount: spine.length,
          loadingBuilder: (context, event) => buildProgressIndicator(context),
          backgroundDecoration: const BoxDecoration(
            image: DecorationImage(
              repeat: ImageRepeat.repeat,
              scale: 0.5,
              image: AssetImage(
                'img/blank_tile.png',
                package: 'ui_commons',
              ),
            ),
          ),
          onPageChanged: publicationController.onPageChanged,
        ),
      );

  PhotoViewGalleryPageOptions _buildItem(Link link, ServerStarted state) =>
      PhotoViewGalleryPageOptions(
        gestureDetectorBehavior: HitTestBehavior.translucent,
        imageProvider: NetworkImage('${state.address}/${link.href}'),
        initialScale: PhotoViewComputedScale.contained * minScaleFactor,
        heroAttributes: PhotoViewHeroAttributes(tag: link.href),
        minScale: PhotoViewComputedScale.contained * minScaleFactor,
        maxScale: PhotoViewComputedScale.contained * maxScaleFactor,
      );

  void onTap() => readerContext?.onTap();
}
