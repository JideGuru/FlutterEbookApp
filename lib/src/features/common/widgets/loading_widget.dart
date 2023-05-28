import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  final bool isImage;

  const LoadingWidget({super.key, this.isImage = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildBody(context),
    );
  }

  StatefulWidget _buildBody(BuildContext context) {
    if (isImage) {
      return SpinKitRipple(
        color: Theme.of(context).colorScheme.secondary,
      );
    } else {
      return SpinKitWave(
        color: Theme.of(context).colorScheme.secondary,
      );
    }
  }
}
