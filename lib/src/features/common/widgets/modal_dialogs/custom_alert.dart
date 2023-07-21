import 'dart:ui';

import 'package:flutter/material.dart';

class CustomAlert extends StatefulWidget {
  final Widget child;

  const CustomAlert({super.key, required this.child});

  @override
  State<CustomAlert> createState() => _CustomAlertState();
}

class _CustomAlertState extends State<CustomAlert> {
  late double deviceWidth;

  late double deviceHeight;

  late double dialogHeight;

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final Size viewsSize = MediaQuery.of(context).size;

    deviceWidth = orientation == Orientation.portrait
        ? viewsSize.width
        : viewsSize.height;
    deviceHeight = orientation == Orientation.portrait
        ? viewsSize.height
        : viewsSize.width;
    dialogHeight = deviceHeight * (0.50);

    return MediaQuery(
      data: const MediaQueryData(),
      child: GestureDetector(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 0.5,
            sigmaY: 0.5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
