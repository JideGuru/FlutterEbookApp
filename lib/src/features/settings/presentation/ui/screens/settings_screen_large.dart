import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';

class SettingsScreenLarge extends StatelessWidget {
  const SettingsScreenLarge({super.key});

  @override
  Widget build(BuildContext context) {
    final isNestedEmpty = context.watchRouter.topRoute.name == 'SettingsRoute';

    return AnimatedPageSplitter(
      isExpanded: !isNestedEmpty,
      leftChild: const SettingsScreenSmall(),
      rightChild: const AutoRouter(),
    );
  }
}
