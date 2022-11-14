import 'package:flutter/material.dart';

class ToolbarPageNumber extends StatelessWidget {
  final int pageNumber;

  const ToolbarPageNumber({Key? key, required this.pageNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          "$pageNumber",
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      );
}
