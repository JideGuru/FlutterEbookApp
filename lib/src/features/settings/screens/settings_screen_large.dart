import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:flutter_ebook_app/src/features/settings/settings.dart';

class SettingsScreenLarge extends StatelessWidget {
  const SettingsScreenLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 400, child: SettingsScreenSmall()),
        VerticalDivider(thickness: 1, width: 2),
        Expanded(child: AutoRouter()),
      ],
    );
  }
}
