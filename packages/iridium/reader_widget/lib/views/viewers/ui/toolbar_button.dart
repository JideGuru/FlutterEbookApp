// Copyright (c) 2021 Mantano. All rights reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.

import 'package:flutter/material.dart';

class ToolbarButton extends StatelessWidget {
  final String asset;
  final VoidCallback onPressed;
  final Color background;
  final double padding;
  final double iconSize;

  const ToolbarButton({
    Key? key,
    required this.asset,
    required this.onPressed,
    this.background = Colors.transparent,
    this.padding = 12.0,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.circle,
        color: background,
        child: IconButton(
          onPressed: onPressed,
          splashRadius: 24.0,
          icon: ImageIcon(
            AssetImage(asset),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: iconSize,
          ),
        ),
      );
}
