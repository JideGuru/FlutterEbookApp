import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:iridium_reader_widget/views/viewers/ui/toolbar_button.dart';
import 'package:iridium_reader_widget/views/viewers/ui/toolbar_page_number.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';

class ReaderToolbar extends StatefulWidget {
  final ReaderContext readerContext;
  final VoidCallback onSkipLeft;
  final VoidCallback onSkipRight;

  const ReaderToolbar(
      {super.key,
      required this.readerContext,
      required this.onSkipLeft,
      required this.onSkipRight});

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

  Function() get onSkipLeft => widget.onSkipLeft;

  Function() get onSkipRight => widget.onSkipRight;

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

  Widget _firstRow(BuildContext context) {
    var isReversed =
        readerContext.readingProgression?.isReverseOrder() ?? false;
    return Row(
      children: <Widget>[
        ToolbarButton(
          asset:
              'packages/iridium_reader_widget/assets/images/ic_skip_left_white_24dp.png',
          onPressed: onSkipLeft,
        ),
        const SizedBox(width: 8.0),
        (isReversed ? _buildNbPages(context) : _builderCurrentPage()),
        _buildSlider(context),
        (isReversed ? _builderCurrentPage() : _buildNbPages(context)),
        const SizedBox(width: 8.0),
        ToolbarButton(
          asset:
              'packages/iridium_reader_widget/assets/images/ic_skip_right_white_24dp.png',
          onPressed: onSkipRight,
        ),
      ],
    );
  }

  Widget _builderCurrentPage() => StreamBuilder<int>(
        initialData: 1,
        stream: pageNumberController.stream,
        builder: (context, snapshot) => ToolbarPageNumber(
          pageNumber: snapshot.data ?? 1,
        ),
      );
  // Widget _builderCurrentPage() => StreamBuilder<int>(
  //       initialData: 1,
  //       stream: pageNumberController.stream,
  //       builder: (context, snapshot) {
  //         var isReversed =
  //             readerContext.readingProgression?.isReverseOrder() ?? false;
  //         var nbPages = readerContext.publication?.nbPages ?? 1;
  //         var curPageNumber = snapshot.data ?? 1;
  //         return ToolbarPageNumber(
  //           pageNumber:
  //               (isReversed ? nbPages - curPageNumber + 1 : curPageNumber),
  //         );
  //       },
  //     );

  Widget _buildNbPages(BuildContext context) => ToolbarPageNumber(
        pageNumber: readerContext.publication?.nbPages ?? 1,
      );

  Widget _buildSlider(BuildContext context) => Expanded(
        child: StreamBuilder<int>(
            initialData: 1,
            stream: pageNumberController.stream,
            builder: (context, snapshot) {
              var isReversed =
                  readerContext.readingProgression?.isReverseOrder() ?? false;
              var maxPageNumber =
                  readerContext.publication?.nbPages.toDouble() ?? 1;
              var curPageNum = snapshot.data?.toDouble() ?? 1;
              return FlutterSlider(
                  rtl: isReversed,
                  onDragging: (handlerIndex, lowerValue, upperValue) =>
                      pageNumberController.add(lowerValue.toInt()),
                  onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                    readerContext.execute(GoToPageCommand(lowerValue.toInt()));
                  },
                  min: 1.0,
                  max: maxPageNumber,
                  values: [curPageNum],
                  trackBar: FlutterSliderTrackBar(
                    inactiveTrackBarHeight: 4,
                    activeTrackBarHeight: 6,
                    inactiveTrackBar: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      //border: Border.all(width: 3, color: Colors.blue),
                    ),
                    activeTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  handler: FlutterSliderHandler(
                    child: Icon(
                      Icons.adjust,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ));
              // return Slider(
              //   onChanged: (value) => pageNumberController.add(value.toInt()),
              //   onChangeEnd: (value) {
              //     readerContext.execute(GoToPageCommand(value.toInt()));
              //   },
              //   min: 1.0,
              //   max: readerContext.publication?.nbPages.toDouble() ?? 1,
              //   value: snapshot.data?.toDouble() ?? 1,
              //   activeColor: Theme.of(context).colorScheme.onPrimaryContainer,
              //   inactiveColor: Theme.of(context).colorScheme.onPrimaryContainer,
              // );
            }),
      );
}
