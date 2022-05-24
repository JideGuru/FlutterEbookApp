import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iridium_reader_widget/views/viewers/ui/toolbar_button.dart';
import 'package:iridium_reader_widget/views/viewers/ui/toolbar_page_number.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class ReaderToolbar extends StatefulWidget {
  final ReaderContext readerContext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const ReaderToolbar(
      {Key? key,
      required this.readerContext,
      required this.onPrevious,
      required this.onNext})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ReaderToolbarState();
}

class ReaderToolbarState extends State<ReaderToolbar> {
  static const double height = kToolbarHeight;
  late StreamSubscription<bool> _toolbarStreamSubscription;
  late StreamSubscription<PaginationInfo> _currentLocationStreamSubscription;
  late StreamController<int> pageNumberController;
  double opacity = 0.0;

  ReaderContext get readerContext => widget.readerContext;

  Function() get onPrevious => widget.onPrevious;

  Function() get onNext => widget.onNext;

  @override
  void initState() {
    super.initState();
    _toolbarStreamSubscription = readerContext.toolbarStream.listen((visible) {
      setState(() {
        opacity = (visible) ? 1.0 : 0.0;
      });
    });
    pageNumberController = StreamController.broadcast();
    _currentLocationStreamSubscription =
        readerContext.currentLocationStream.listen((event) {
      pageNumberController.add(event.page);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _toolbarStreamSubscription.cancel();
    _currentLocationStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: IgnorePointer(
          ignoring: opacity < 1.0,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 300),
            child: Container(
              height: height,
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _firstRow(context),
            ),
          ),
        ),
      );

  Widget _firstRow(BuildContext context) => Row(
        children: <Widget>[
          ToolbarButton(
            asset: 'packages/iridium_reader_widget/assets/images/ic_skip_previous_white_24dp.png',
            onPressed: onPrevious,
          ),
          const SizedBox(width: 8.0),
          _builderCurrentPage(),
          _buildSlider(context),
          _buildNbPages(context),
          const SizedBox(width: 8.0),
          ToolbarButton(
            asset: 'packages/iridium_reader_widget/assets/images/ic_skip_next_white_24dp.png',
            onPressed: onNext,
          ),
        ],
      );

  Widget _builderCurrentPage() => StreamBuilder<int>(
        initialData: 1,
        stream: pageNumberController.stream,
        builder: (context, snapshot) => ToolbarPageNumber(
          pageNumber: snapshot.data ?? 1,
        ),
      );

  Widget _buildNbPages(BuildContext context) => ToolbarPageNumber(
        pageNumber: readerContext.publication?.nbPages ?? 1,
      );

  Widget _buildSlider(BuildContext context) => Expanded(
        child: StreamBuilder<int>(
            initialData: 1,
            stream: pageNumberController.stream,
            builder: (context, snapshot) => Slider(
                  onChanged: (value) => pageNumberController.add(value.toInt()),
                  onChangeEnd: (value) {
                    readerContext.execute(GoToPageCommand(value.toInt()));
                  },
                  min: 1.0,
                  max: readerContext.publication?.nbPages.toDouble() ?? 1,
                  value: snapshot.data?.toDouble() ?? 1,
                  activeColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  inactiveColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                )),
      );
}
