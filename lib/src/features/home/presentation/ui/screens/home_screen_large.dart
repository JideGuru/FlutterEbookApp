import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ebook_app/src/common/common.dart';
import 'package:flutter_ebook_app/src/features/features.dart';

class HomeScreenLarge extends StatelessWidget {
  const HomeScreenLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: context.screenSize.width / 2.7,
          child: const HomeScreenSmall(),
        ),
        const VerticalDivider(thickness: 1, width: 2),
        const Expanded(child: AutoRouter()),
      ],
    );
  }
}
